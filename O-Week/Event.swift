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
    let categories: [String]
    let startTimeUnixRep: Double
    let endTimeUnixRep: Double
    let startTime: Time
    let endTime: Time
    let date: Date
    let longitude: Double
    let latitude: Double
    let pk: String
    let firstYearRequired: Bool
    let transferRequired: Bool
    let url: String
    let img: String
    
    var hashValue: Int
    {
        return pk.hashValue
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
            - latitude: latitude of the event location
            - longitude: longitude of the event location
			- pk: Unique positive ID given to each event starting from 1.
	*/
    private init(title:String, caption:String, categories:[String], pk: String, start: Double, end: Double, description: String, longitude: Double, latitude: Double, firstYearRequired: Bool, transferRequired: Bool, url: String, img:String)
    {
        self.title = title
        self.caption = caption
        self.categories = categories
        self.description = description
        self.pk = pk
		self.longitude = longitude
        self.latitude = latitude
        self.firstYearRequired = firstYearRequired
        self.transferRequired = transferRequired
        self.url = url
        self.img = img
        
        self.startTimeUnixRep = start
        self.endTimeUnixRep = end
        let startTime = Date(timeIntervalSince1970: start / 1000)
        let endTime = Date(timeIntervalSince1970: end / 1000)
        self.date = UserData.userCalendar.date(bySettingHour: 0, minute: 0, second: 0, of: startTime)!
        self.startTime = Time(hour: UserData.userCalendar.component(.hour, from: startTime), minute: UserData.userCalendar.component(.minute, from: startTime))
        self.endTime = Time(hour: UserData.userCalendar.component(.hour, from: endTime), minute: UserData.userCalendar.component(.minute, from: endTime))
        
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
                let pk = json["pk"] as? String,
                let description = json["description"] as? String,
                let location = json["location"] as? String,
                let categories = json["categories"] as? [String],
                let latitude = json["latitude"] as? Double,
                let longitude = json["longitude"] as? Double,
                let startTime = json["start"] as? Double,
                let endTime = json["end"] as? Double,
                let firstYearRequired = json["firstYearRequired"] as? Bool,
                let transferRequired = json["transferRequired"] as? Bool,
                let url = json["url"] as? String,
                let img = json["img"] as? String
        else {
			print("Event.jsonOptional: incorrect JSON format")
            return nil
        }
        
        
        self.pk = pk
        self.title = title
        self.caption = location
        self.description = description
        self.categories = categories
		self.firstYearRequired = firstYearRequired
		self.transferRequired = transferRequired
        self.latitude = latitude
        self.longitude = longitude
        self.img = img
        self.url = url
        
        self.startTimeUnixRep = startTime
        self.endTimeUnixRep = endTime
        let start = Date(timeIntervalSince1970: startTime / 1000)
        let end = Date(timeIntervalSince1970: endTime / 1000)
        self.date = UserData.userCalendar.date(bySettingHour: 0, minute: 0, second: 0, of: start)!
        self.startTime = Time(hour: UserData.userCalendar.component(.hour, from: start), minute: UserData.userCalendar.component(.minute, from: start))
        self.endTime = Time(hour: UserData.userCalendar.component(.hour, from: end), minute: UserData.userCalendar.component(.minute, from: end))
    }
	
	/**
		Convert this event to a string to save to disk.
		- returns: String representation of this object.
	*/
	func toString() -> String
	{
		var stringRep =  "\(title)|\(caption)|\(description)|\(pk)|\(startTimeUnixRep)|\(endTimeUnixRep)|\(firstYearRequired)|\(transferRequired)|\(longitude)|\(latitude)|\(url)|\(img)|"
        for (index, category) in categories.enumerated() {
            stringRep += category
            if(index < categories.count - 1) {
                stringRep += ";"
            }
        }
        return stringRep
	}
	
	/**
		Creates an event object from its string representation.
		- parameter str: String representation of an event.
		- returns: Event object.
	*/
	static func fromString(_ str: String) -> Event?
	{
		let parts = str.components(separatedBy: "|")
		guard parts.count >= 13,
			let startTimeUnixRep = Double(parts[4]),
            let endTimeUnixRep = Double(parts[5]),
			let firstYearRequired = Bool(parts[6]),
			let transferRequired = Bool(parts[7]),
            let longitude = Double(parts[8]),
            let latitude = Double(parts[9])
        else {
				print("Invalid event string: \(str)")
				return nil
		}
		
		let title = parts[0]
		let caption = parts[1]
		let description = parts[2]
		let pk = parts[3]
        let url = parts[10]
        let img = parts[11]
		
        let categories = parts[12].components(separatedBy: ";")
		
		return Event(title: title, caption: caption, categories: categories, pk: pk, start: startTimeUnixRep, end: endTimeUnixRep, description: description, longitude: longitude, latitude: latitude, firstYearRequired: firstYearRequired, transferRequired: transferRequired, url: url, img: img)
	}
	
//    /** DEPRECATED
//        Returns the formatted additional text, with headers and bullets.
//        String is like so: ## HEADER ## ____BULLET # INFO ____BULLET # INFO.
//        - important: Check that `additional` is not empty before calling this method.
//
//        - returns: Formatted text
//    */
//    func attributedAdditional() -> NSAttributedString
//    {
//        let TEXT_SIZE:CGFloat = 16
//
//        let string = NSMutableAttributedString()
//        let headerAndRemaining = additional.components(separatedBy: "##")
//        let header = "\(headerAndRemaining[1].trimmingCharacters(in: .whitespacesAndNewlines))\n"
//        let remaining = headerAndRemaining[2].trimmingCharacters(in: .whitespacesAndNewlines)
//
//        //set header
//        let headerAttributes = [NSAttributedStringKey.font: UIFont(name: Font.DEMIBOLD, size: TEXT_SIZE)!]
//        let attributedHeader = NSAttributedString(string: header, attributes: headerAttributes)
//        string.append(attributedHeader)
//
//        let sections = remaining.components(separatedBy: "____")
//        for section in sections
//        {
//            guard !section.isEmpty else {
//                continue
//            }
//            let bulletAndInfo = section.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " # ")
//            let bullet = "\(bulletAndInfo[0])\t"
//            let info = "\(bulletAndInfo[1])\n"
//
//            //set bullet
//            let attributedBullet = NSAttributedString(string: bullet, attributes:[.font: UIFont(name: Font.DEMIBOLD, size: TEXT_SIZE)!, .foregroundColor: Colors.RED])
//            string.append(attributedBullet)
//
//            //set info
//            let attributedInfo = NSAttributedString(string: info, attributes: [.font:UIFont(name: Font.REGULAR, size: 14)!, .foregroundColor: Colors.LIGHT_GRAY])
//            string.append(attributedInfo)
//        }
//
//        return string
//    }
	
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
