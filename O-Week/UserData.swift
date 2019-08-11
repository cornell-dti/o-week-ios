//
//  UserData.swift
//  O-Week
//
//  Created by Vicente Caycedo on 4/28/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import Foundation
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
	static let eventsName = "events" //KeyPath where events are saved
	static let categoriesName = "categories" //KeyPath where categories are saved
    static let resourcesName = "resources" //KeyPath were resources are saved
	static let defaults = UserDefaults.standard
    
    //Events
	static var allEvents = [Date: [String:Event]]()
	static var selectedEvents = [Date: [String:Event]]()
    
    //Calendar for manipulating dates. You can use this throughout the app.
    static let userCalendar = Calendar.current
    
    //resources
    static var resources = [Resource]()
    
    //Dates
    static var DATES = [Date]()
	static var selectedDate:Date!
	static let YEAR = 2019
	static let MONTH = 8
	static let START_DAY = 23	//Dates range: [START_DAY, END_DAY], inclusive
	static let DURATION = 15		//Duration of orientation dates
	
	//Categories
	static var categories = [String:Category]()
	
	//User identity
	static var studentTypePk:String? = nil
	static var collegePk:String? = nil
	
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
        var count = 0
		while (count < DURATION)
		{
			let date = UserData.userCalendar.date(from: dateComponents)!
			DATES.append(date)
			selectedEvents[date] = [String:Event]()
			allEvents[date] = [String:Event]()
			dateComponents.day! += 1
            count += 1
			
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
		let storedStudentPk = defaults.string(forKey: studentTypeName) ?? ""
		let storedCollegePk = defaults.string(forKey: collegeTypeName) ?? ""
		
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
        getResources()
		getEvents()
		getCategories()
        		
		let addedPKs = getAddedPKs()
		addedPKs.forEach({pk in
			if let event = eventFor(pk) {
				insertToSelectedEvents(event)
			}
		})
        
        Internet.getResourceLinks(onCompletion: {
            resources in
            print("completed fetching resources")
            
            self.resources = []
            for resource in resources {
                self.resources.append(resource)
            }
            
            saveResources()
        })
		
		//access database for updates
		Internet.getUpdatesForVersion(version, onCompletion:
		{
			newVersion, changedCategories, deletedCategoryPks, changedEvents, deletedEventPks in
            
            print("completed fetching, new version:\(newVersion)")
			
			//update categories
			changedCategories.forEach({categories[$0.pk] = $0})
			deletedCategoryPks.forEach({categories.removeValue(forKey: $0)})
			saveCategories()
			
			//update events
			changedEvents.forEach({updateEvent($0)})
			for date in DATES
			{
				deletedEventPks.forEach({pk in
					allEvents[date]?.removeValue(forKey: pk)
					selectedEvents[date]?.removeValue(forKey: pk)
				})
			}
			saveEvents()
			
			//all version updates have been processed. Now, load events that the user has selected into selectedEvents (again).
			addedPKs.forEach({pk in
				if let event = eventFor(pk) {
					insertToSelectedEvents(event)
				}
			})
			
			//delete and resend notifications
			let changedSelectedEvents = changedEvents.filter({addedPKs.contains($0.pk)})
			if (BoolPreference.Reminder.isTrue())
			{
				deletedEventPks.forEach({LocalNotifications.removeNotification(for: $0)})
				changedSelectedEvents.forEach({LocalNotifications.createNotification(for: $0)})
			}
			
			//notify user of event updates
			LocalNotifications.addNotification(for: changedSelectedEvents)
			
			//save updated database version
			version = newVersion
		})
	}
	
	/**
		Returns true if the event is required for the user based on the user's identity.
		- parameter event: The event to check.
		- returns: True if the event is required for this user in particular, false otherwise.
	*/
	static func requiredForUser(event: Event) -> Bool
	{
		if let student = studentTypePk,
            let college = collegePk {
            if event.firstYearRequired && student == Student.Freshmen.pk && event.categories.contains(college) {
                return true
            }
            if event.transferRequired && student == Student.Transfer.pk && event.categories.contains(college) {
                return true
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
            return eventsForDate[event.pk] != nil
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
            return setForDate[event.pk] != nil
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
            print("appendToAllEvents: attempted to add event with date outside orientation: \(event.pk), \(event.date)")
			return
		}
		allEvents[event.date]![event.pk] = event
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
		selectedEvents[event.date]![event.pk] = event
    }
	/**
		Removes event from `selectedEvents`.
		- parameter event: Event to remove.
		- returns: True IFF an event was actually removed.
	*/
	@discardableResult
    static func removeFromSelectedEvents(_ event: Event) -> Bool
	{
		for day in DATES
		{
			let removed = selectedEvents[day]!.removeValue(forKey: event.pk) != nil
			if (removed) {
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
		for day in DATES
		{
			let removed = allEvents[day]!.removeValue(forKey: event.pk) != nil
			if (removed) {
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
	static func eventFor(_ pk:String) -> Event?
	{
		return allEvents.values.first(where: {$0[pk] != nil})?[pk]
	}
	/**
		Updates an event that might've been already on disk with one from the database. Performs the following actions:
	
		1. Adds new event, removing its old copy
		2. Attempt to remove old event from selected events. If we did remove something, that means the old event was selected, so we should then select the new updated event. `removeFromSelected()` also matches event by equality, which is based on `pk`.
	
		- parameter event: Updated event. Should have same `pk` as old event, if old event exists.
	*/
	static func updateEvent(_ event:Event)
	{
		removeFromAllEvents(event)
		appendToAllEvents(event)
		
		//if the event was selected, make sure it still is. Otherwise, we don't care.
		if (removeFromSelectedEvents(event))
		{
			insertToSelectedEvents(event)
		}
	}
	
	// MARK:- Image saving, reading, and deletion.
	
	/**
		Saves the given `UIImage` on the iPhone with a `.png` extension.
		
		- parameters:
			- image: Image to save.
			- event: The pk of the event this image belongs to. The image will be saved with the `event.pk` as its name so we can access it next time using the event.
	*/
	static func saveImage(_ image:UIImage, eventPk:String)
	{
		let imageData = UIImagePNGRepresentation(image)
		let url = documentURLForName("\(eventPk).png")
		try? imageData?.write(to: url)
	}
	/**
		Deletes the image of the given event from disk.
	
		- parameter event: Event whose image we wish to delete.
	*/
	static func removeImageOf(_ eventPk:String)
	{
		let url = documentURLForName("\(eventPk).png")
		try? FileManager.default.removeItem(at: url)
	}
	/**
		Reads from disk an image for the given event.
	
		- parameter event: Event whose image we wish to read from disk.
		- returns: Image if one was found, nil otherwise.
	*/
	static func loadImageFor(_ eventPk:String) -> UIImage?
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
	static func getAddedPKs() -> [String]
	{
		return defaults.object(forKey: addedPKsName) as? [String] ?? [String]()
	}
	/**
		Saves to `UserDefaults` the `event.pk`s of events the user has selected.
	*/
    static func saveAddedPKs()
	{
        let addedPks = selectedEvents.values.flatMap({$0.keys})
        defaults.set(addedPks, forKey: addedPKsName)
    }
	/**
		The version of the database we have saved on this phone. This value is passed to the database to determine what needs to be updated. This value is then synchronized with the database's current version.
	*/
	static var version:Double {
		get
		{
			//if version was not set, defaults.integer returns 0, which is what we want
			return defaults.double(forKey: versionName)
		}
		set
		{
			defaults.set(newValue, forKey: versionName)
		}
	}
	/**
		Saves what type of student the user is.
		- parameter pk: Pk of the category that is the user's identity. Should match values in `Student`.
	*/
	static func setStudentType(pk:String)
	{
		defaults.set(pk, forKey: studentTypeName)
		studentTypePk = pk
	}
	/**
		Saves the college the user is in.
		- parameter pk: Pk of the category that is the user's college. Should match values in `Colleges`.
	*/
	static func setCollegeType(pk:String)
	{
		defaults.set(pk, forKey: collegeTypeName)
		collegePk = pk
	}
	static func saveEvents()
	{
		let events = allEvents.values.flatMap({$0.values}).map({$0.toString()})
		defaults.set(events, forKey: eventsName)
	}
	static func getEvents()
	{
		guard let events = defaults.array(forKey: eventsName) as? [String] else {
			return
		}
		events.compactMap({Event.fromString($0)}).forEach({appendToAllEvents($0)})
	}
	static func saveCategories()
	{
		defaults.set(categories.values.map({$0.toString()}), forKey: categoriesName)
	}
	static func getCategories()
	{
		guard let saved = defaults.array(forKey: categoriesName) as? [String] else {
			return
		}
		saved.map({Category.fromString($0)!}).forEach({categories[$0.pk] = $0})
	}
    static func saveResources()
    {
        let resources_strs = resources.map({$0.toString()})
        defaults.set(resources_strs, forKey: resourcesName)
    }
    static func getResources() {
        guard let resources = defaults.array(forKey: resourcesName) as? [String] else {
            return
        }
        self.resources = []
        resources.compactMap({Resource.fromString($0)}).forEach({self.resources.append($0)})
    }
	/**
		Returns whether or not this is the first time the user's opened the app.
		Based on whether the college pk value is saved.
		- returns: True if the user had not used the app before.
	*/
	static func isFirstRun() -> Bool
	{
		let collegeTypePk = defaults.string(forKey: collegeTypeName) ?? ""
		return Colleges.collegeForPk(collegeTypePk) == nil
	}
}
