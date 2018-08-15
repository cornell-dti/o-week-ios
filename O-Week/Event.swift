//
//  Event.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

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
struct Event:Hashable, Comparable, JSONObject
{
    let title: String
    let caption: String
    let description: String
    let category: Int
    let startTime: Time
    let endTime: Time
    let required: Bool
    let date: Date
	let placeId: String
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
			- placeId: String from Google to identify location
			- pk: Unique positive ID given to each event starting from 1.
	*/
	private init(title:String, caption:String, category:Int, pk: Int, start:Time, end:Time, date: Date, required: Bool, description: String, placeId: String, categoryRequired:Bool, additional:String)
    {
        self.title = title
        self.caption = caption
        self.category = category
        self.description = description
        self.date = date
        self.required = required
        self.pk = pk
        startTime = start
        endTime = end
		self.placeId = placeId
		self.categoryRequired = categoryRequired
		self.additional = additional
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
				place_ID => String
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
				let placeId = json["place_ID"] as? String,
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
		self.placeId = placeId
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
		Convert this event to a string to save to disk.
		- returns: String representation of this object.
	*/
	func toString() -> String
	{
		let year = UserData.userCalendar.component(.year, from: date)
		let month = UserData.userCalendar.component(.month, from: date)
		let day = UserData.userCalendar.component(.day, from: date)
		return "\(title)|\(caption)|\(description)|\(category)|\(pk)|\(startTime.hour)|\(startTime.minute)|\(endTime.hour)|\(endTime.minute)|\(required)|\(year)|\(month)|\(day)|\(placeId)|\(categoryRequired)|\(additional)"
	}
	
	/**
		Creates an event object from its string representation.
		- parameter str: String representation of an event.
		- returns: Event object.
	*/
	static func fromString(_ str: String) -> Event?
	{
		let parts = str.components(separatedBy: "|")
		guard parts.count >= 17,
			let category = Int(parts[3]),
			let pk = Int(parts[4]),
			let startHour = Int(parts[5]),
			let startMinute = Int(parts[6]),
			let endHour = Int(parts[7]),
			let endMinute = Int(parts[8]),
			let required = Bool(parts[9]),
			let year = Int(parts[10]),
			let month = Int(parts[11]),
			let day = Int(parts[12]),
			let categoryRequired = Bool(parts[14]) else {
				print("Invalid event string: \(str)")
				return nil
		}
		
		let title = parts[0]
		let caption = parts[1]
		let description = parts[2]
		let placeId = parts[13]
		let additional = parts[15]
		
		let start = Time(hour: startHour, minute: startMinute)
		let end = Time(hour: endHour, minute: endMinute)
		var components = DateComponents()
		components.year = year
		components.month = month
		components.day = day
		let date = UserData.userCalendar.date(from: components)!
		
		return Event(title: title, caption: caption, category: category, pk: pk, start: start, end: end, date: date, required: required, description: description, placeId: placeId, categoryRequired: categoryRequired, additional: additional)
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
	return lhs.startTime < rhs.startTime
}
