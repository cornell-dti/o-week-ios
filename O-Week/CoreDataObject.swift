//
//  CoreDataObject.swift
//  O-Week
//
//  Created by David Chu on 2017/6/23.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataObject
{
	init(_ obj: NSManagedObject)
	@discardableResult
	func saveToCoreData(entity: NSEntityDescription, context: NSManagedObjectContext) -> NSManagedObject
	static var entityName:String { get }
}
