//
//  Event.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import Foundation

struct Event:Hashable
{
    let title:String
    let caption:String
    let startTime:Time
    let endTime:Time
    var hashValue: Int
    {
        var hash = title.hashValue
        hash = 31 &* caption.hashValue &+ hash      //overflow add and overflow multiply
        hash = 31 &* startTime.hashValue &+ hash
        hash = 31 &* endTime.hashValue &+ hash
        return hash
    }
    
    init(title:String, caption:String, start:Time, end:Time)
    {
        self.title = title
        self.caption = caption
        startTime = start
        endTime = end
    }
}
func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.title == rhs.title && lhs.caption == rhs.caption && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
}
