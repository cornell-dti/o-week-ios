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
    
    //Core Data
    static let eventEntityName = "EventEntity"
    static let addedPKsName = "AddedPKs" //KeyPath used for accessing added PKs in User Defaults
    
    //Settings
    static let allSettings: [(name: String, options: [String])] = [(name: "Receive reminders for...", options: ["No events", "All my events", "Only required events"]), (name: "Notify me...", options: ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"])]
    
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
        print("Error: removeFromSelectedEvents attempted on unselected event")
    }
	
	/**
	 * Saves given event to CoreData and also appends it to the array of all events.
	 */
	static func saveEvent(_ event:Event)
	{
		appendToAllEvents(event)
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: UserData.eventEntityName, in: managedContext)!
		event.saveToCoreData(entity: entity, context: managedContext)
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
    
    // MARK:- Core Data Helper Functions
    
    static func loadData()
	{
		initDates()
		
        /* Fetching Core Data */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: UserData.eventEntityName)
		guard let data = try? managedContext.fetch(fetchRequest) else {
			print("loadData: could not read from core data")
			return
		}
		
		//TODO: Implement update
		
        if (data.isEmpty)
		{
			dates.forEach({Internet.getEventsOn($0)})
        }
		else
		{
			/* Fetching PKs of added events */
			let defaults = UserDefaults.standard
			let added = defaults.object(forKey: addedPKsName) as? Set<Int> ?? Set<Int>()
			
			let unprocessedEvents = data.map({Event($0)}).filter({!allEventsContains($0)})
			//add unprocessed events to list of all events
			unprocessedEvents.forEach({appendToAllEvents($0)})
			//add to selected events (if we saved this event before and said it was selected
			unprocessedEvents.filter({!selectedEventsContains($0)}).filter({added.contains($0.pk)}).forEach({insertToSelectedEvents($0)})
			
			//Telling other classes to reload their data
			NotificationCenter.default.post(name: .reload, object: nil)
			NotificationCenter.default.post(name: .reloadDateData, object: nil)
		}
    }
    
    static func savePKs()
	{
        let defaults = UserDefaults.standard
        var addedPks = Set<Int>()
		UserData.selectedEvents.values.flatMap({$0}).forEach({addedPks.insert($0.pk)})
        defaults.setValue(addedPks, forKey: UserData.addedPKsName)
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
