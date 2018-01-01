//
//  UserData.swift
//  O-Week
//
//  Created by Vicente Caycedo on 4/28/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/**
	Handles all data shared between classes. Many of these variables have associated `NotificationCenter` events that should be fired when they are changed, so do so when changing their values.

	`allEvents`: All events on disk, sorted by date.
	`selectedEvents`: All events selected by the user, sorted by date.
	`categories`: All categories on disk.
	`DATES`: Dates of the orientation. Determined from `YEAR`, `MONTH`, `START_DAY`,
	and `END_DAY`.
	`selectedDate`: The date to display events for.
*/
class UserData
{
    //UserDefaults keys
    static let addedPKsName = "AddedPKs" //KeyPath used for accessing added PKs
	static let versionName = "version" //KeyPath used for accessing local version to compare with database
	static let studentTypeName = "student" //KeyPath used for accessing whether the student is a transfer. See `Student` and `studentTypePk`.
	static let collegeTypeName = "college" //KeyPath used for accessing the college of the user. See `Colleges` and `collegePk`.
    
    //Events
    static var allEvents = [Date: [Event]]()
    static var selectedEvents = [Date: [Event]]()
    
    //Calendar for manipulating dates. You can use this throughout the app.
    static let userCalendar = Calendar.current
    
    //Dates
    static var DATES = [Date]()
	static var selectedDate:Date!
	static let YEAR = 2018
	static let MONTH = 1
	static let START_DAY = 18	//Dates range: [START_DAY, END_DAY], inclusive
	static let END_DAY = 23		//Note: END_DAY must > START_DAY
	
	//Categories
	static var categories = [Category]()
	
	//User identity
	static var studentTypePk:Int? = nil
	static var collegePk:Int? = nil
	
    private init(){}
	
	/**
		Initialize `DATES` and lists for dictionaries of events
	*/
	private static func initDates()
	{
		let today = Date()
		var dateComponents = DateComponents()
		dateComponents.year = YEAR
		dateComponents.month = MONTH
		dateComponents.day = START_DAY
		
		selectedDate = UserData.userCalendar.date(from: dateComponents)!
		
		//this assumes END_DAY is larger than START_DAY
		while (dateComponents.day! <= END_DAY)
		{
			let date = UserData.userCalendar.date(from: dateComponents)!
			DATES.append(date)
			selectedEvents[date] = []
			allEvents[date] = []
			dateComponents.day! += 1
			
			if (UserData.userCalendar.compare(today, to: date, toGranularity: .day) == .orderedSame)
			{
				selectedDate = date
			}
		}
	}
	/**
		Sets `studentTypePk` and `collegePk` according to saved values.
	*/
	private static func initStudentIdentity()
	{
		let defaults = UserDefaults.standard
		let storedStudentPk = defaults.integer(forKey: studentTypeName)
		let storedCollegePk = defaults.integer(forKey: collegeTypeName)
		
		//the integer might be the default value (and not something we saved). Check.
		if (Student.studentForPk(storedStudentPk) != nil)
		{
			studentTypePk = storedStudentPk
		}
		if (Colleges.collegeForPk(storedCollegePk) != nil)
		{
			collegePk = storedCollegePk
		}
	}
	/**
		Instantiates `allEvents`, `selectedEvents`, `categories` by reading from CoreData and interacting with the database.
	
		- note: Call whenever the app enters foreground or is launched.
	
		1. Retrieves all events and categories from `CoreData`, adding them to `allEvents`, `categories`.
		2. Sorts all events and categories. This is because downloading is done in the background, and before we've finished downloading, the UI may already need to display events & categories.
		3. Downloads updates from the database; updates categories & events.
		4. Retrieves selected events.
		5. If the user has reminders turned on, remove all deleted events' notifications, and update the updated events' notifications.
		6. Tell the user which of their selected events have been updated.
		7. Sort again with updated events.
		8. Save new database version.
	*/
	static func loadData()
	{
		initDates()
		initStudentIdentity()
		
		//load from CoreData
		let eventData = fetchFromCoreData(Event.self)
		eventData.map({Event($0)})
			.filter({!allEventsContains($0)})
			.forEach({appendToAllEvents($0)})
		
		let categoryData = fetchFromCoreData(Category.self)
		categories = categoryData.map({Category($0)})
			.filter({!categories.contains($0)})
		
		let addedPKs = getAddedPKs()
		let selectedEventsArray = selectedEvents.values.flatMap({$0})
		allEvents.values.flatMap({$0})
			.filter({addedPKs.contains($0.pk)})
			.filter({!selectedEventsArray.contains($0)})
			.forEach({insertToSelectedEvents($0)})
		
		sortEventsAndCategories()
		
		//access database for updates
		Internet.getUpdatesForVersion(version, onCompletion:
		{
			newVersion, changedCategories, deletedCategoryPks, changedEvents, deletedEventPks in
			
			//update categories
			changedCategories.forEach({updateCategory($0)})
			deletedCategoryPks.forEach({removeFromCoreData(entityName: Category.entityName, pk: $0)})
			categories = categories.filter({!deletedCategoryPks.contains($0.pk)})
			
			//update events
			changedEvents.forEach({updateEvent($0)})
			deletedEventPks.forEach({
				eventPk in
				UserData.removeFromCoreData(entityName: Event.entityName, pk: eventPk)
				UserData.removeImageOf(eventPk)
			})
			for date in DATES
			{
				allEvents[date] = allEvents[date]!.filter({!deletedEventPks.contains($0.pk)})
				selectedEvents[date] = selectedEvents[date]!.filter({!deletedEventPks.contains($0.pk)})
			}
			
			//all version updates have been processed. Now, load events that the user has selected into selectedEvents (again).
			let selectedEventsArray = selectedEvents.values.flatMap({$0})
			allEvents.values.flatMap({$0})
				.filter({addedPKs.contains($0.pk)})
				.filter({!selectedEventsArray.contains($0)})
				.forEach({insertToSelectedEvents($0)})
			
			//delete and resend notifications
			let changedSelectedEvents = changedEvents.filter({addedPKs.contains($0.pk)})
			if (BoolPreference.Reminder.isTrue())
			{
				deletedEventPks.forEach({LocalNotifications.removeNotification(for: $0)})
				changedSelectedEvents.forEach({LocalNotifications.createNotification(for: $0)})
			}
			
			//notify user of event updates
			LocalNotifications.addNotification(for: changedSelectedEvents)
			
			//sort again after updates
			sortEventsAndCategories()
			
			//save updated database version
			version = newVersion
		})
	}
	/**
		Sorts `allEvents` and `categories`.
	*/
	private static func sortEventsAndCategories()
	{
		for (date, events) in allEvents
		{
			allEvents[date] = events.sorted()
		}
		categories = categories.sorted()
	}
	
	/**
		Returns true if the event is required for the user based on the user's identity.
		- parameter event: The event to check.
		- returns: True if the event is required for this user in particular, false otherwise.
	*/
	static func requiredForUser(event: Event) -> Bool
	{
		if (event.required)
		{
			return true
		}
		if (event.categoryRequired)
		{
			if let student = studentTypePk
			{
				if (student == event.category)
				{
					//required for student's type
					return true
				}
			}
			if let college = collegePk
			{
				if (college == event.category)
				{
					//required for student's college
					return true
				}
			}
		}
		return false
	}
	
    // MARK:- Search Functions

	/**
		Returns whether or not the event is in `allEvents`.
		- parameter event: Event to check.
		- returns: True if `allEvents` already holds a copy of the given event.
	*/
    static func allEventsContains(_ event: Event) -> Bool
	{
        if let eventsForDate = allEvents[event.date] {
            return eventsForDate.contains(event)
        } else {
            return false
        }
    }
	/**
		Returns true if the event is selected.
		- parameter event: The event that we want to check is selected.
		- returns: See method description.
	*/
    static func selectedEventsContains(_ event: Event) -> Bool
	{
        if let setForDate = selectedEvents[event.date] {
            return setForDate.contains(event)
        } else {
            return false
        }
    }
	/**
		Adds event to `allEvents` for the correct date according to `event.date`.
		The date should match a date in `DATES`.
		- parameter event: Event to add.
	*/
    static func appendToAllEvents(_ event: Event)
	{
		guard allEvents[event.date] != nil else {
			print("appendToAllEvents: attempted to add event with date outside orientation")
			return
		}
		allEvents[event.date]!.append(event)
    }
	/**
		Adds event to `selectedEvents`. The date should match a date in `DATES`.
		- parameter event: Event to add.
		- returns: True if the event was added
	*/
    static func insertToSelectedEvents(_ event: Event)
	{
		guard selectedEvents[event.date] != nil else {
			print("insertToSelectedEvents: attempted to add event with date outside orientation")
			return
		}
		selectedEvents[event.date]!.append(event)
    }
	/**
		Removes event from `selectedEvents`.
		- parameter event: Event to remove.
		- returns: True IFF an event was actually removed.
	*/
	@discardableResult
    static func removeFromSelectedEvents(_ event: Event) -> Bool
	{
        if let array = selectedEvents[event.date]
		{
            if let index = array.index(of: event)
			{
                selectedEvents[event.date]!.remove(at: index)
				return true
            }
        }
		return false
    }
	/**
		Removes event from `allEvents`.
		- parameter event: Event to remove.
		- returns: True IFF an event was actually removed.
	*/
	@discardableResult
	static func removeFromAllEvents(_ event:Event) -> Bool
	{
		if let array = allEvents[event.date]
		{
			if let index = array.index(of: event)
			{
				allEvents[event.date]!.remove(at: index)
				return true
			}
		}
		return false
	}
	/**
		Linear search for a event given its pk value.
		- parameter pk: `Event.pk`
		- returns: Event, nil if no match was found.
	*/
	static func eventFor(_ pk:Int) -> Event?
	{
		return allEvents.flatMap({$0.value}).first(where: {$0.pk == pk})
	}
	/**
		Linear search for a category given its pk value.
		- parameter pk: `Category.pk`
		- returns: Category, nil if no match was found.
	*/
	static func categoryFor(_ pk:Int) -> Category?
	{
		return categories.first(where: {$0.pk == pk})
	}
	/**
		Updates an event that might've been already on disk with one from the database. Performs the following actions:
	
		1. Removes old event from list (`removeFromAllEvents()` matches event by equality, which is based on `pk`, and since an updated event should have the same `pk` as the old event, calling `removeFromAllEvents(newEvent)` should remove the old event).
		2. Adds new event.
		3. Removes old event from `CoreData` (again, using the `pk`. Look at `removeFromCoreData()` for details).
		4. Saves new event to `CoreData`.
		5. Attempt to remove old event from selected events. If we did remove something, that means the old event was selected, so we should then select the new updated event. `removeFromSelected()` also matches event by equality, which is based on `pk`.
	
		- note: Pictures CANNOT be updated with this method (for now). To update an event's picture, the best way would be to delete the event and add a new one (both done on the database), with a different pk.
		- parameter event: Updated event. Should have same `pk` as old event, if old event exists.
	*/
	static func updateEvent(_ event:Event)
	{
		removeFromAllEvents(event)
		appendToAllEvents(event)
		removeFromCoreData(entityName: Event.entityName, pk: event.pk)
		saveToCoreData(event)
		
		//if the event was selected, make sure it still is. Otherwise, we don't care.
		if (removeFromSelectedEvents(event))
		{
			insertToSelectedEvents(event)
		}
	}
	/**
		Updates a category that might've been already on disk with one from the database. Performs the following actions:
	
		1. Checks to see if there exists an old category to be replaced. If there is, then remove the old one from the list and from `CoreData`.
		2. Adds new category.
		3. Saves new category to `CoreData`.
		
		- parameter category: Updated category. Should have same `pk` as old category, if old category exists.
	*/
	static func updateCategory(_ category:Category)
	{
		if let indexToRemove = categories.index(of: category)
		{
			categories.remove(at: indexToRemove)
			removeFromCoreData(entityName: Category.entityName, pk: category.pk)
		}
		categories.append(category)
		saveToCoreData(category)
	}
	
	// MARK:- Core Data interactions
	
	/**
		Saves the given object to `CoreData` asynchronously.
		- parameter object: Object to save. Should implement `CoreDataObject` protocol.
	*/
	static func saveToCoreData(_ object:CoreDataObject)
	{
		CoreData.persistentContainer.performBackgroundTask(
		{
			(context) in
			let entity = NSEntityDescription.entity(forEntityName: type(of: object).entityName, in: context)!
			object.saveToCoreData(entity: entity, context: context)
			try? context.save()
		})
	}
	/**
		Removes an object with the `pk` from `CoreData`.
		- parameters:
 			- entityName: Type of object.
			- pk: Unique id of object.
	*/
	static func removeFromCoreData(entityName:String, pk:Int)
	{
		CoreData.persistentContainer.performBackgroundTask(
		{
			(context) in
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
			fetchRequest.predicate = NSPredicate(format: "pk = %@", argumentArray: [pk])
			let fetchedResults = try? context.fetch(fetchRequest)
			fetchedResults?.forEach({context.delete($0 as! NSManagedObject)})
		})
	}
	/**
		Returns an array of `NSManagedObjects` from `CoreData` of the given type.
		- parameter type: The entity type of the objects you want to read.
		- returns: Array of `NSManagedObjects` of the entity type given.
	*/
	private static func fetchFromCoreData(_ type:CoreDataObject.Type) -> [NSManagedObject]
	{
		let managedContext = CoreData.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
		return try! managedContext.fetch(fetchRequest)
	}
	
	// MARK:- Image saving, reading, and deletion.
	
	/**
		Saves the given `UIImage` on the iPhone with a `.png` extension.
		
		- parameters:
			- image: Image to save.
			- event: The pk of the event this image belongs to. The image will be saved with the `event.pk` as its name so we can access it next time using the event.
	*/
	static func saveImage(_ image:UIImage, eventPk:Int)
	{
		let imageData = UIImagePNGRepresentation(image)
		let url = documentURLForName("\(eventPk).png")
		try? imageData?.write(to: url)
	}
	/**
		Deletes the image of the given event from disk.
	
		- parameter event: Event whose image we wish to delete.
	*/
	static func removeImageOf(_ eventPk:Int)
	{
		let url = documentURLForName("\(eventPk).png")
		try? FileManager.default.removeItem(at: url)
	}
	/**
		Reads from disk an image for the given event.
	
		- parameter event: Event whose image we wish to read from disk.
		- returns: Image if one was found, nil otherwise.
	*/
	static func loadImageFor(_ eventPk:Int) -> UIImage?
	{
		let url = documentURLForName("\(eventPk).png")
		return UIImage(contentsOfFile: url.path)
	}
	/**
		Provides a path to the file for the given file name.
		- parameter name: Name of the file.
		- returns: Path to the file.
	*/
	private static func documentURLForName(_ name:String) -> URL
	{
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[0].appendingPathComponent(name)
	}
	
	
	// MARK:- UserDefaults interactions
	
	/**
		Retrieves from `UserDefaults` a list of `event.pk`s of events the user has selected.
		- returns: List of `pk`s belonging to selected events.
	*/
	static func getAddedPKs() -> [Int]
	{
		let defaults = UserDefaults.standard
		return defaults.object(forKey: addedPKsName) as? [Int] ?? [Int]()
	}
	/**
		Saves to `UserDefaults` the `event.pk`s of events the user has selected.
	*/
    static func saveAddedPKs()
	{
        let defaults = UserDefaults.standard
        let addedPks = selectedEvents.values.flatMap({$0}).map({$0.pk})
        defaults.set(addedPks, forKey: addedPKsName)
    }
	/**
		The version of the database we have saved on this phone. This value is passed to the database to determine what needs to be updated. This value is then synchronized with the database's current version.
	*/
	static var version:Int {
		get
		{
			//if version was not set, defaults.integer returns 0, which is what we want
			let defaults = UserDefaults.standard
			return defaults.integer(forKey: versionName)
		}
		set
		{
			let defaults = UserDefaults.standard
			defaults.set(newValue, forKey: versionName)
		}
	}
	/**
		Saves what type of student the user is.
		- parameter pk: Pk of the category that is the user's identity. Should match values in `Student`.
	*/
	static func setStudentType(pk:Int)
	{
		let defaults = UserDefaults.standard
		defaults.set(pk, forKey: studentTypeName)
		studentTypePk = pk
	}
	/**
		Saves the college the user is in.
		- parameter pk: Pk of the category that is the user's college. Should match values in `Colleges`.
	*/
	static func setCollegeType(pk:Int)
	{
		let defaults = UserDefaults.standard
		defaults.set(pk, forKey: collegeTypeName)
		collegePk = pk
	}
	/**
		Returns whether or not this is the first time the user's opened the app.
		Based on whether the college pk value is saved.
		- returns: True if the user had not used the app before.
	*/
	static func isFirstRun() -> Bool
	{
		let defaults = UserDefaults.standard
		let collegeTypePk = defaults.integer(forKey: collegeTypeName)
		return Colleges.collegeForPk(collegeTypePk) == nil
	}
}
