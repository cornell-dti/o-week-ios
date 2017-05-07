//
//  Event.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation
import CoreData

struct Event:Hashable
{
    let title: String
    let caption: String
    let description: String
    let category: String
    let startTime: Time
    let endTime: Time
    let required: Bool
    let date: Date
    let pk: String
    
    //TODO: change hash function
    var hashValue: Int
    {
        var hash = title.hashValue
        hash = 31 &* caption.hashValue &+ hash      //overflow add and overflow multiply
        hash = 31 &* startTime.hashValue &+ hash
        hash = 31 &* endTime.hashValue &+ hash
        return hash
    }
    
    init(title:String, caption:String, category:String, pk: String, start:Time, end:Time, date: Date, required: Bool, description: String?)
    {
        self.title = title
        self.caption = caption
        self.description = description ?? "No description available at this time."
        self.date = date
        self.required = required
        self.pk = pk
        startTime = start
        endTime = end
    }
    
    init(_ obj: NSManagedObject){
        self.title = obj.value(forKeyPath: "title") as! String
        self.caption = obj.value(forKeyPath: "caption") as! String
        self.description = obj.value(forKeyPath: "eventDescription") as? String ?? "No description available at this time"
        category = "Default"
        self.startTime = Time(hour: obj.value(forKeyPath: "startTimeHr") as! Int, minute: obj.value(forKeyPath: "startTimeMin") as! Int)
        self.endTime = Time(hour: obj.value(forKeyPath: "endTimeHr") as! Int, minute: obj.value(forKeyPath: "endTimeMin") as! Int)
        self.required = obj.value(forKeyPath: "required") as! Bool
        self.date = obj.value(forKeyPath: "date") as! Date
        self.pk = obj.value(forKeyPath: "pk") as! String
    }
    
    init?(json: [String:Any])
    {
        guard let title = json["name"] as? String,
                let pk = json["pk"] as? String,
                let description = json["description"] as? String,
                let location = json["location"] as String,
                let category = json["category"] as? String,
                let startDate = json["start_date"] as? String,
                let startTime = json["start_time"] as? String,
                let endTime = json["end_time"] as? String
        else {
            return nil
        }
        
        self.pk = pk
        self.title = title
        self.caption = location
        self.description = description
        self.category = category
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat("yyyy-MM-dd")
        date = dateFormatter.date(from: startDate)
        
        self.startTime = Time.fromString(startTime)
        self.endTime = Time.fromString(endTime)
    }
}

func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.title == rhs.title && lhs.caption == rhs.caption && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime && lhs.date == rhs.date
}
