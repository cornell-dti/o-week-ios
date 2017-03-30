//
//  Time.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import Foundation

struct Time:Hashable, CustomStringConvertible
{
    let hour:Int
    let minute:Int
    var description:String
    {
        //from 24HR format to 12HR format
        if (hour > 12)
        {
            return String(format: "\(hour - 12):%02d PM", minute)
        }
        else if (hour == 12)
        {
            return String(format: "12:%02d PM", minute)
        }
        else if (hour == 0)
        {
            return String(format: "12:%02d AM", minute)
        }
        else
        {
            return String(format: "\(hour):%02d AM", minute)
        }
    }
    var hourDescription:String
    {
        if (hour > 12)
        {
            return String(format: "\(hour - 12) PM", minute)
        }
        else if (hour == 12)
        {
            return String(format: "12 PM", minute)
        }
        else if (hour == 0)
        {
            return String(format: "12 AM", minute)
        }
        else
        {
            return String(format: "\(hour) AM", minute)
        }
    }
    var hashValue: Int
    {
        return toMinutes()
    }
    
    init()
    {
        let date = Date()
        let components = NSCalendar.current.dateComponents([.hour, .minute], from: date)
        self.hour = components.hour!
        self.minute = components.minute!
    }
    init(hour:Int, minute:Int)
    {
        self.hour = hour
        self.minute = minute
    }
    init(hour:Int)
    {
        self.hour = hour
        minute = 0
    }
    //expected format: "10:00 AM"
    static func fromString(_ timeString:String) -> Time
    {
        let hourAndMin = timeString.components(separatedBy: ":")    //"10", "00 AM"
        guard hourAndMin.count == 2 else {
            print("Time.fromString incorrect time: \(timeString)")
            return Time(hour: 0, minute: 0)
        }
        
        let minAndAMPM = hourAndMin[1].components(separatedBy: " ") //"00", "AM"
        guard minAndAMPM.count == 2 else {
            print("Time.fromString incorrect time: \(timeString)")
            return Time(hour: 0, minute: 0)
        }
        
        let hour12 = Int(hourAndMin[0])!
        
        let hour24 = minAndAMPM[1] == "AM" ? hour12 : hour12 + 12
        let min = Int(minAndAMPM[0])!
        
        return Time(hour: hour24, minute: min)
    }
    func toMinutes() -> Int
    {
        return hour * 60 + minute;
    }
    static func fromMinutes(_ minutes:Int) -> Time
    {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return Time(hour: hours, minute: remainingMinutes)
    }
    static func add(startTime:Time, minutesToAdd:Int) -> Time
    {
        var timeInMinutes = startTime.toMinutes()
        timeInMinutes += minutesToAdd
        return Time.fromMinutes(timeInMinutes)
    }
    static func length(startTime:Time, endTime:Time) -> Int
    {
        let startTimeInMinutes = startTime.toMinutes()
        let endTimeInMinutes = endTime.toMinutes()
        let length = endTimeInMinutes - startTimeInMinutes
        //wrap around to the next day. 1440 = 24 * 60
        return (length < 0) ? (length + 1440) : length
    }
}

//comparable methods (have to be outside of struct)
func < (lhs:Time, rhs:Time) -> Bool
{
    return lhs.toMinutes() < rhs.toMinutes()
}
func == (lhs:Time, rhs:Time) -> Bool
{
    return lhs.toMinutes() == rhs.toMinutes()
}
