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
    let startTime: Time
    let endTime: Time
    let required: Bool
    let date: Date
    let pk: Int
    
    var hashValue: Int
    {
        var hash = title.hashValue
        hash = 31 &* caption.hashValue &+ hash      //overflow add and overflow multiply
        hash = 31 &* startTime.hashValue &+ hash
        hash = 31 &* endTime.hashValue &+ hash
        return hash
    }
    
    init(title:String, caption:String, pk: Int, start:Time, end:Time, date: Date, required: Bool, description: String?)
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
        self.startTime = Time(hour: obj.value(forKeyPath: "startTimeHr") as! Int, minute: obj.value(forKeyPath: "startTimeMin") as! Int)
        self.endTime = Time(hour: obj.value(forKeyPath: "endTimeHr") as! Int, minute: obj.value(forKeyPath: "endTimeMin") as! Int)
        self.required = obj.value(forKeyPath: "required") as! Bool
        self.date = obj.value(forKeyPath: "date") as! Date
        self.pk = obj.value(forKeyPath: "pk") as! Int
    }
    
}

func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.title == rhs.title && lhs.caption == rhs.caption && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime && lhs.date == rhs.date
}
