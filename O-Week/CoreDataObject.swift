//
//  CoreDataObject.swift
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
protocol CoreDataObject
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
	/**
		The unique value of this object.
	*/
	var pk:Int { get }
}
