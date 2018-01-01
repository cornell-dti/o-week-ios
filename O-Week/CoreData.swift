//
//  CoreData.swift
//  O-Week
//
//  Created by David Chu on 2017/6/23.
//  Copyright © 2017年 Cornell D&TI. All rights reserved.
//

import Foundation
import CoreData

/**
	An object that can be saved to and read from `CoreData`.
*/
protocol CoreDataObject:HasPK
{
	/**
		Reading from `CoreData`.
	
		- important: Should have value fields synced with `O-week.xcdatamodeld` and function `saveToCoreData`.
	
		- parameter obj: `CoreData` object containing key-value fields.
	*/
	init(_ obj: NSManagedObject)
	/**
		Saving to `CoreData`.
	
		- important: Should have value fields synced with `O-week.xcdatamodeld` and function `init(obj)`.
	
		- parameters:
			- entity: Core data magic.
			- context: Core data magic.
	*/
	@discardableResult
	func saveToCoreData(entity: NSEntityDescription, context: NSManagedObjectContext) -> NSManagedObject
	/**
		The name of this "entity" in `CoreData`.
		
		- important: Should be identical to what is listed under `ENTITIES` in `O-week.xcdatamodeld`
	*/
	static var entityName:String { get }
}

/**
	Stores static references to CoreData containers.
*/
class CoreData
{
	static var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "O-Week")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	static func saveContext()
	{
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
}
