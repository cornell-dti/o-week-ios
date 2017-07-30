//
//  Event.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit
import CoreData

struct Event:Hashable, Comparable, CoreDataObject, JSONObject
{
    let title: String
    let caption: String
    let description: String
    let category: Int
    let startTime: Time
    let endTime: Time
    let required: Bool
    let date: Date
	let longitude: Double
	let latitude: Double
	let categoryRequired: Bool
	let additional: String
    let pk: Int
    
    var hashValue: Int
    {
        return pk
    }
	static var entityName: String
	{
		return "EventEntity"
	}
    
	init(title:String, caption:String, category:Int, pk: Int, start:Time, end:Time, date: Date, required: Bool, description: String?, longitude:Double, latitude:Double, categoryRequired:Bool, additional:String)
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
		self.longitude = longitude
		self.latitude = latitude
		self.categoryRequired = categoryRequired
		self.additional = additional
    }
    init(_ obj: NSManagedObject)
	{
        title = obj.value(forKeyPath: "title") as! String
        caption = obj.value(forKeyPath: "caption") as! String
        description = obj.value(forKeyPath: "eventDescription") as? String ?? "No description available at this time"
        category = obj.value(forKey: "category") as! Int
        startTime = Time(hour: obj.value(forKeyPath: "startTimeHr") as! Int, minute: obj.value(forKeyPath: "startTimeMin") as! Int)
        endTime = Time(hour: obj.value(forKeyPath: "endTimeHr") as! Int, minute: obj.value(forKeyPath: "endTimeMin") as! Int)
        required = obj.value(forKeyPath: "required") as! Bool
        date = obj.value(forKeyPath: "date") as! Date
        pk = obj.value(forKeyPath: "pk") as! Int
		longitude = obj.value(forKey: "longitude") as! Double
		latitude = obj.value(forKey: "latitude") as! Double
		categoryRequired = obj.value(forKey: "categoryRequired") as! Bool
		additional = obj.value(forKey: "additional") as! String
    }
    init?(jsonOptional: [String:Any]?)
    {
        guard let json = jsonOptional,
				let title = json["name"] as? String,
                let pk = json["pk"] as? Int,
                let description = json["description"] as? String,
                let location = json["location"] as? String,
                let category = json["category"] as? Int,
                let startDate = json["start_date"] as? String,
                let startTime = json["start_time"] as? String,
                let endTime = json["end_time"] as? String,
				let required = json["required"] as? Bool,
			//convert first to String, then to Double. Converting directly to Double will create an error
				let longitudeStr = json["longitude"] as? String,
				let longitude = Double(longitudeStr),
				let latitudeStr = json["latitude"] as? String,
				let latitude = Double(latitudeStr),
				let categoryRequired = json["category_required"] as? Bool,
				let additional = json["additional"] as? String else {
			print("Event.jsonOptional: incorrect JSON format")
            return nil
        }
        
        self.pk = pk
        self.title = title
        self.caption = location
        self.description = description
        self.category = category
		self.required = required
		self.longitude = longitude
		self.latitude = latitude
		self.categoryRequired = categoryRequired
		self.additional = additional
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: startDate) else {
            return nil
        }
        self.date = date
        
        self.startTime = Time.fromString(startTime)
        self.endTime = Time.fromString(endTime)
    }
	
	func saveToCoreData(entity: NSEntityDescription, context: NSManagedObjectContext) -> NSManagedObject
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
		obj.setValue(longitude, forKey: "longitude")
		obj.setValue(latitude, forKey: "latitude")
		obj.setValue(categoryRequired, forKey: "categoryRequired")
		obj.setValue(additional, forKey: "additional")
		return obj
	}
	
	//assumes additional is non empty and is formatted like so:
	// ## HEADER ## ____BULLET # INFO ____BULLET # INFO
	func attributedAdditional() -> NSAttributedString
	{
		let TEXT_SIZE:CGFloat = 12
		let TAB_STOP:CGFloat = 64
		
		let string = NSMutableAttributedString()
		let headerAndRemaining = additional.components(separatedBy: "##")
		let header = "\(headerAndRemaining[1].trimmingCharacters(in: .whitespacesAndNewlines))\n"
		let remaining = headerAndRemaining[2].trimmingCharacters(in: .whitespacesAndNewlines)
		
		//set header
		let headerAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: TEXT_SIZE)!]
		let attributedHeader = NSAttributedString(string: header, attributes: headerAttributes)
		string.append(attributedHeader)
		
		let sections = remaining.components(separatedBy: "____")
		for section in sections
		{
			guard !section.isEmpty else {
				continue
			}
			let bulletAndInfo = section.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " # ")
			let bullet = "\(bulletAndInfo[0])\t"
			let info = "\(bulletAndInfo[1])\n"
			let start = string.length
			
			//set bullet
			let bulletAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: TEXT_SIZE)!, NSForegroundColorAttributeName:Constants.Colors.RED]
			let attributedBullet = NSAttributedString(string:bullet, attributes:bulletAttributes)
			string.append(attributedBullet)
			
			//set info
			let attributedInfo = NSAttributedString(string: info)
			string.append(attributedInfo)
			
			//set paragraph style
			let infoParagraphStyle = NSMutableParagraphStyle()
			infoParagraphStyle.headIndent = TAB_STOP
			infoParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: TAB_STOP)]
			string.addAttribute(NSParagraphStyleAttributeName, value: infoParagraphStyle, range: NSRange(location: start, length: bullet.characters.count + info.characters.count))
		}
		
		return string
	}
}

func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.pk == rhs.pk
}
func < (lhs:Event, rhs:Event) -> Bool
{
	let dateCompare = UserData.userCalendar.compare(lhs.date, to: rhs.date, toGranularity: .day)
	if (dateCompare != .orderedSame)
	{
		return dateCompare == .orderedAscending
	}
	
	//If lhs starts in the next day and rhs in the previous
	if (lhs.startTime.hour <= ScheduleVC.END_HOUR && rhs.startTime.hour >= ScheduleVC.START_HOUR)
	{
		return false
	}
	//If lhs starts in the previous day and rhs in the next
	if (lhs.startTime.hour >= ScheduleVC.START_HOUR && rhs.startTime.hour <= ScheduleVC.END_HOUR)
	{
		return true
	}
	return lhs.startTime.hour < rhs.startTime.hour
}
