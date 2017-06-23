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
    
    //Persistent Data
    static let addedPKsName = "AddedPKs" //KeyPath used for accessing added PKs in User Defaults
    
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
	static let START_DAY = 19	//Dates range: [START_DAY, END_DAY], inclusive
	static let END_DAY = 24
	
	//Categories
	static var categories = [Category]()
    
    private init(){}
    
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
    
    static func removeFromSelectedEvents(_ event: Event)
	{
        if let array = selectedEvents[event.date]
		{
            if let index = array.index(of: event)
			{
                selectedEvents[event.date]!.remove(at: index)
                return
            }
        }
    }
	
	static func appendToCategories(_ category:Category)
	{
		categories.append(category)
	}
	
	static func saveToCoreData(_ object:CoreDataObject)
	{
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: type(of: object).entityName, in: managedContext)!
		object.saveToCoreData(entity: entity, context: managedContext)
		try? managedContext.save()
	}
	
	static func saveImage(_ image:UIImage, event:Event)
	{
		let imageData = UIImagePNGRepresentation(image)
		let url = documentURLForName("\(event.pk).png")
		try? imageData?.write(to: url)
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
	
	/**
	 Attempts to fetch 
	*/
	private static func fetchFromCoreData(_ type:CoreDataObject.Type) -> [NSManagedObject]
	{
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
		let data = try? managedContext.fetch(fetchRequest)
		return data!
	}
	
    // MARK:- Core Data Helper Functions
    
    static func loadData()
	{
		initDates()
		
		let eventData = fetchFromCoreData(Event)
		let categoryData = fetchFromCoreData(Category)
		
		//TODO: Implement update
		
		//handle events
        if (eventData.isEmpty)
		{
			dates.forEach({Internet.getEventsOn($0)})
        }
		else
		{
			/* Fetching PKs of added events */
			let defaults = UserDefaults.standard
			let added = defaults.object(forKey: addedPKsName) as? [Int] ?? [Int]()
			
			let unprocessedEvents = eventData.map({Event($0)}).filter({!allEventsContains($0)})
			//add unprocessed events to list of all events
			unprocessedEvents.forEach({appendToAllEvents($0)})
			//add to selected events (if we saved this event before and said it was selected
			unprocessedEvents.filter({!selectedEventsContains($0)}).filter({added.contains($0.pk)}).forEach({insertToSelectedEvents($0)})
			
			//Telling other classes to reload their data
			NotificationCenter.default.post(name: .reloadData, object: nil)
		}
		
		//handle categories
		if (categoryData.isEmpty)
		{
			Internet.getCategories()
		}
		else
		{
			categories = categoryData.map({Category($0)})
		}
    }
    
    static func savePKs()
	{
        let defaults = UserDefaults.standard
        var addedPks = [Int]()
		UserData.selectedEvents.values.flatMap({$0}).forEach({addedPks.append($0.pk)})
        defaults.set(addedPks, forKey: UserData.addedPKsName)
    }
	
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
    
}
