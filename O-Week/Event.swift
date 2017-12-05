//
//  Event.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit
import CoreData

/**
	Data-type that holds all information about an event. Designed to be immutable. This will be downloaded from the database via methods in `Internet`, where new events will be compared with saved ones.

	Notable fields are explained below:

	`category`: The `Category.pk` of the `Category` this event belongs to.
	`date`: The date in which this event BEGINS. If this event crosses over midnight, the date is that of the 1st day.
	`categoryRequired`: True if this event is required by its category.
	`additional`: Additional information to display in a special format. Formatted like so:
			## HEADER ## ____BULLET # INFO ____BULLET # INFO

	- Important: Since events can cross over midnight, the `endTime` may not be "after" the `#startTime`. Calculations should take this into account.

	- Note: see `Category`
*/
struct Event:Hashable, Comparable, CoreDataObject, JSONObject
{
	static let entityName = "EventEntity"
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
	
	/**
		Creates an event object in-app. This should never be done organically (without initial input from the database in some form), or else we risk becoming out-of-sync with the database.
		- parameters:
			- title: For example, "New Student Check-In"
			- caption: For example, "Bartels Hall"
			- description: For example, "You are required to attend New Student Check-In to pick up..."
			- category: See class description.
			- date: For example, 7/19/2017
			- start: For example, 8:00 AM
			- end: For example, 4:00 PM
			- required: Whether this event is required for new students.
			- categoryRequired: Whether this event is required for its category.
			- additional: For example, ## All new students are required to attend this program at the following times: ## ____3:30pm # Residents of Balch, Jameson, Risley, Just About Music, Ecology House, and Latino Living Center; on-campus transfers in Call Alumni Auditorium ____5:30pm # Residents of Dickson, McLLU, Donlon, High Rise 5, and Ujamaa; off-campus transfers in Call Alumni Auditorium ____8:00pm # Residents of Townhouses, Low Rises, Court-Kay-Bauer, Mews, Holland International Living Center, and Akwe:kon
			- longitude: For example, -76.4785000
			- latitude: For example, 42.4439000
			- pk: Unique positive ID given to each event starting from 1.
	*/
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
	/**
		Creates an event from saved `CoreData`.
		
		- important: Should have value fields synced with `O-week.xcdatamodeld` and function `saveToCoreData`.
		
		- parameter obj: Object retrieved from `CoreData`. Expects fields:
				title  => String
				caption => String
				pk => int
				eventDescription => String
				category => int
				startTimeHr => int
				startTimeMin => int
				endTimeHr => int
				endTimeMin => int
				required => bool
				date => Date
				longitude => Double
				latitude => Double
				categoryRequired => boolean
				additional => String
	*/
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
	/**
		Creates an event object using data downloaded from the database.
		
		- parameter jsonOptional: JSON with the expected keys and values:
				name  => String
				location => String
				pk => int
				description => String
				category => int
				start_time => Time. See `Time.fromString()`
				end_time => Time. See `Time.fromString()`
				required => bool
				start_date => Date, formatted as "yyyy-MM-dd"
				longitude => Double
				latitude => Double
				category_required => boolean
				additional => String
	*/
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
	/**
		Sets this event to the `CoreData` context given; for saving events.
		
		- important: Should have value fields synced with `O-week.xcdatamodeld` and function `init(obj)`.
		
		- parameters:
			- entity: Core data magic.
			- context: Core data magic.
	*/
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
	
	/**
		Returns the formatted additional text, with headers and bullets.
		String is like so: ## HEADER ## ____BULLET # INFO ____BULLET # INFO.
		- important: Check that `additional` is not empty before calling this method.
		
		- returns: Formatted text
	*/
	func attributedAdditional() -> NSAttributedString
	{
		let TEXT_SIZE:CGFloat = 16
		
		let string = NSMutableAttributedString()
		let headerAndRemaining = additional.components(separatedBy: "##")
		let header = "\(headerAndRemaining[1].trimmingCharacters(in: .whitespacesAndNewlines))\n"
		let remaining = headerAndRemaining[2].trimmingCharacters(in: .whitespacesAndNewlines)
		
		//set header
		let headerAttributes = [NSAttributedStringKey.font: UIFont(name: Font.DEMIBOLD, size: TEXT_SIZE)!]
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
			
			//set bullet
			let attributedBullet = NSAttributedString(string: bullet, attributes:[.font: UIFont(name: Font.DEMIBOLD, size: TEXT_SIZE)!, .foregroundColor: Colors.RED])
			string.append(attributedBullet)
			
			//set info
			let attributedInfo = NSAttributedString(string: info, attributes: [.font:UIFont(name: Font.REGULAR, size: 14)!, .foregroundColor: Colors.LIGHT_GRAY])
			string.append(attributedInfo)
		}
		
		return string
	}
	
	/**
		Returns the date as "DayOfWeek, Month DayOfMonth".
		For example, "Saturday, Aug 18".
	*/
	func readableDate() -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE, MMM d"
		return dateFormatter.string(from: date)
	}
}
/**
	Returns whether lhs == rhs. True if `pk`s are identical.
	- parameters:
		- lhs: `Event` on left of ==
		- rhs: `Event` on right of ==
	- returns: See description.
*/
func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.pk == rhs.pk
}
/**
	Returns whether lhs < rhs. Ordering is based on start time, taking into account events that may start after midnight.
	- parameters:
		- lhs: `Event` on left of <
		- rhs: `Event` on right of <
	- returns: True if lhs < rhs.
*/
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
