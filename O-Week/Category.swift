//
//  Category.swift
//  O-Week
//
//  Created by David Chu on 2017/6/23.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import Foundation
import CoreData

struct Category:Hashable, CoreDataObject, JSONObject
{
	let pk:Int
	let name:String
	let description:String
	var hashValue: Int
	{
		return pk
	}
	static var entityName: String
	{
		return "CategoryEntity"
	}
	
	init(pk:Int, name:String, description:String)
	{
		self.pk = pk
		self.name = name
		self.description = description
	}
	init(_ obj: NSManagedObject)
	{
		self.pk = obj.value(forKeyPath: "pk") as! Int
		self.name = obj.value(forKey: "name") as! String
		self.description = obj.value(forKey: "categoryDescription") as! String
	}
	init?(jsonOptional: [String:Any]?)
	{
		guard let json = jsonOptional,
			let pk = json["pk"] as? Int,
			let name = json["category"] as? String,
			let description = json["description"] as? String else {
				return nil
		}
		
		self.init(pk:pk, name:name, description:description)
	}
	func saveToCoreData(entity: NSEntityDescription, context: NSManagedObjectContext) -> NSManagedObject
	{
		let obj = NSManagedObject(entity: entity, insertInto: context)
		obj.setValue(pk, forKeyPath: "pk")
		obj.setValue(name, forKeyPath: "name")
		obj.setValue(description, forKeyPath: "categoryDescription")
		return obj
	}
}
func == (lhs:Category, rhs:Category) -> Bool
{
	return lhs.pk == rhs.pk
}
