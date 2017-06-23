//
//  Event.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation
import CoreData

struct Event:Hashable, CoreDataObject
{
    let title: String
    let caption: String
    let description: String
    let category: Int
    let startTime: Time
    let endTime: Time
    let required: Bool
    let date: Date
    let pk: Int
    
    var hashValue: Int
    {
        return pk
    }
	static var entityName: String
	{
		return "EventEntity"
	}
    
    init(title:String, caption:String, category:Int, pk: Int, start:Time, end:Time, date: Date, required: Bool, description: String?)
    {
        self.title = title
        self.caption = caption
        self.category = category
        self.description = description ?? "No description available at this time."
        self.date = date
        self.required = required
        self.pk = pk
        startTime = start
        endTime = end
    }
    
    init(_ obj: NSManagedObject)
	{
        self.title = obj.value(forKeyPath: "title") as! String
        self.caption = obj.value(forKeyPath: "caption") as! String
        self.description = obj.value(forKeyPath: "eventDescription") as? String ?? "No description available at this time"
        self.category = obj.value(forKey: "category") as! Int
        self.startTime = Time(hour: obj.value(forKeyPath: "startTimeHr") as! Int, minute: obj.value(forKeyPath: "startTimeMin") as! Int)
        self.endTime = Time(hour: obj.value(forKeyPath: "endTimeHr") as! Int, minute: obj.value(forKeyPath: "endTimeMin") as! Int)
        self.required = obj.value(forKeyPath: "required") as! Bool
        self.date = obj.value(forKeyPath: "date") as! Date
        self.pk = obj.value(forKeyPath: "pk") as! Int
    }
    
    init?(json: [String:Any])
    {
        guard let title = json["name"] as? String,
                let pk = json["pk"] as? Int,
                let description = json["description"] as? String,
                let location = json["location"] as? String,
                let category = json["category"] as? Int,
                let startDate = json["start_date"] as? String,
                let startTime = json["start_time"] as? String,
                let endTime = json["end_time"] as? String,
				let required = json["required"] as? Bool
        else {
            return nil
        }
        
        self.pk = pk
        self.title = title
        self.caption = location
        self.description = description
        self.category = category
		self.required = required
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: startDate) else {
            return nil
        }
        self.date = date
        
        self.startTime = Time.fromString(startTime)
        self.endTime = Time.fromString(endTime)
    }
	
	func saveToCoreData(entity: NSEntityDescription, context: NSManagedObjectContext)
	{
		let obj = NSManagedObject(entity: entity, insertInto: context)
		obj.setValue(title, forKeyPath: "title")
		obj.setValue(caption, forKeyPath: "caption")
		obj.setValue(description, forKeyPath: "eventDescription")
		obj.setValue(pk, forKeyPath: "pk")
		obj.setValue(startTime.hour, forKeyPath: "startTimeHr")
		obj.setValue(startTime.minute, forKeyPath: "startTimeMin")
		obj.setValue(endTime.hour, forKeyPath: "endTimeHr")
		obj.setValue(endTime.minute, forKeyPath: "endTimeMin")
		obj.setValue(required, forKeyPath: "required")
		obj.setValue(date, forKeyPath: "date")
		obj.setValue(category, forKey: "category")
	}
}

func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.pk == rhs.pk
}
