//
//  UserData.swift
//  O-Week
//
//  Created by Vicente Caycedo on 4/28/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//
//  Holds a variety of user data

import Foundation
import CoreData
import UIKit

class UserData {
    
    // MARK:- Properties
    
    //UserDefaults
    static let addedPKsName = "AddedPKs" //KeyPath used for accessing added PKs
	static let versionName = "version" //KeyPath used for accessing local version to compare with database
    
    //Events
    static var allEvents = [Date: [Event]]()
    static var selectedEvents = [Date: [Event]]()
    
    //Calendar 
    static let userCalendar = Calendar.current
    
    //Dates
    static var dates = [Date]()
	static var selectedDate:Date!
	static let YEAR = 2017
	static let MONTH = 8
	static let START_DAY = 18	//Dates range: [START_DAY, END_DAY], inclusive
	static let END_DAY = 26
	
	//Categories
	static var categories = [Category]()
	
    private init(){}
	
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
			dates.append(date)
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
		Instantiates all necessary events, categories, and dates by reading from CoreData and interacting with the database. Should be called whenever the app enters foreground or is launched.
	*/
	static func loadData()
	{
		initDates()
		
		//load from CoreData
		let eventData = fetchFromCoreData(Event.self)
		eventData.map({Event($0)})
			.filter({!allEventsContains($0)})
			.forEach({appendToAllEvents($0)})
		
		let categoryData = fetchFromCoreData(Category.self)
		categories = categoryData.map({Category($0)})
			.filter({!categories.contains($0)})
		
		//access database for updates
		Internet.getUpdatesForVersion(version, onCompletion:
		{
			//all version updates have been processed. Now, load events that the user has selected into selectedEvents.
			let addedPKs = getAddedPKs()
			let selectedEventsArray = selectedEvents.values.flatMap({$0})
			allEvents.values.flatMap({$0})
				.filter({addedPKs.contains($0.pk)})
				.filter({!selectedEventsArray.contains($0)})
				.forEach({insertToSelectedEvents($0)})
		})
	}
	
    // MARK:- Search Functions
    
    static func allEventsContains(_ event: Event) -> Bool
	{
        if let eventsForDate = allEvents[event.date] {
            return eventsForDate.contains(event)
        } else {
            return false
        }
    }
    static func selectedEventsContains(_ event: Event) -> Bool
	{
        if let setForDate = selectedEvents[event.date] {
            return setForDate.contains(event)
        } else {
            return false
        }
    }
    static func appendToAllEvents(_ event: Event)
	{
		guard allEvents[event.date] != nil else {
			print("appendToAllEvents: attempted to add event with date outside orientation")
			return
		}
		allEvents[event.date]!.append(event)
    }
    static func insertToSelectedEvents(_ event: Event)
	{
		guard selectedEvents[event.date] != nil else {
			print("insertToSelectedEvents: attempted to add event with date outside orientation")
			return
		}
		selectedEvents[event.date]!.append(event)
    }
	//Returns true if an event was actually removed
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
	@discardableResult
	static func removeFromAllEvents(_ event:Event) -> Bool
	{
		if let array = allEvents[event.date]
		{
			if let index = array.index(of: event)
			{
				allEvents[event.date]!.remove(at: index)
				removeFromCoreData(event)
				removeImageOf(event)
				return true
			}
		}
		return false
	}
	static func updateEvent(_ event:Event)
	{
		removeFromAllEvents(event)
		appendToAllEvents(event)
		saveToCoreData(event)
		
		//if the event was selected, make sure it still is. Otherwise, we don't care.
		if (removeFromSelectedEvents(event))
		{
			insertToSelectedEvents(event)
		}
	}
	static func updateCategory(_ category:Category)
	{
		if let indexToRemove = categories.index(of: category)
		{
			categories.remove(at: indexToRemove)
			removeFromCoreData(category)
		}
		categories.append(category)
		saveToCoreData(category)
	}
	
	// MARK:- Core Data interactions
	
	static func saveToCoreData(_ object:CoreDataObject)
	{
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.persistentContainer.performBackgroundTask(
		{
			(context) in
			let entity = NSEntityDescription.entity(forEntityName: type(of: object).entityName, in: context)!
			object.saveToCoreData(entity: entity, context: context)
			try? context.save()
		})
	}
	static func removeFromCoreData(_ object:CoreDataObject)
	{
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.persistentContainer.performBackgroundTask(
		{
			(context) in
			let entity = NSEntityDescription.entity(forEntityName: type(of: object).entityName, in: context)!
			context.delete(object.saveToCoreData(entity: entity, context: context))
		})
	}
	static func saveImage(_ image:UIImage, event:Event)
	{
		let imageData = UIImagePNGRepresentation(image)
		let url = documentURLForName("\(event.pk).png")
		try? imageData?.write(to: url)
	}
	static func removeImageOf(_ event:Event)
	{
		let url = documentURLForName("\(event.pk).png")
		try? FileManager.default.removeItem(at: url)
	}
	static func loadImageFor(_ event:Event) -> UIImage?
	{
		let url = documentURLForName("\(event.pk).png")
		return UIImage(contentsOfFile: url.path)
	}
	private static func documentURLForName(_ name:String) -> URL
	{
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[0].appendingPathComponent(name)
	}
	private static func fetchFromCoreData(_ type:CoreDataObject.Type) -> [NSManagedObject]
	{
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
		return try! managedContext.fetch(fetchRequest)
	}
	
	// MARK:- UserDefaults interactions
	
	static func getAddedPKs() -> [Int]
	{
		let defaults = UserDefaults.standard
		return defaults.object(forKey: addedPKsName) as? [Int] ?? [Int]()
	}
    static func saveAddedPKs()
	{
        let defaults = UserDefaults.standard
        var addedPks = [Int]()
		UserData.selectedEvents.values.flatMap({$0}).forEach({addedPks.append($0.pk)})
        defaults.set(addedPks, forKey: UserData.addedPKsName)
    }
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
}
