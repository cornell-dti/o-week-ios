//
//  Event.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation

class Event:Hashable
{
    let title: String
    let caption: String
    let description: String
    let startTime: Time
    let endTime: Time
    let required: Bool
    
    var added: Bool
    var hashValue: Int
    {
        var hash = title.hashValue
        hash = 31 &* caption.hashValue &+ hash      //overflow add and overflow multiply
        hash = 31 &* startTime.hashValue &+ hash
        hash = 31 &* endTime.hashValue &+ hash
        return hash
    }
    
    init(title:String, caption:String, start:Time, end:Time, added: Bool, required: Bool, description: String?)
    {
        self.title = title
        self.caption = caption
        self.description = description ?? "No description available at this time."
        self.added = added
        self.required = required
        startTime = start
        endTime = end
    }
    
}

func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.title == rhs.title && lhs.caption == rhs.caption && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
}
