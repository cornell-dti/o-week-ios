//
//  Time.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation

struct Time:Comparable, Hashable, CustomStringConvertible
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
    //expected format: "10:00:00"
    static func fromString(_ timeString:String) -> Time
    {
        let hourAndMin = timeString.components(separatedBy: ":")    //"10", "00"
        let hour = Int(hourAndMin[0])
        let min = Int(hourAndMin[1])
        return Time(hour: hour!, minute: min!)
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
func > (lhs:Time, rhs:Time) -> Bool
{
    return lhs.toMinutes() > rhs.toMinutes()
}
func >= (lhs:Time, rhs:Time) -> Bool
{
    return lhs.toMinutes() >= rhs.toMinutes()
}
func <= (lhs:Time, rhs:Time) -> Bool
{
    return lhs.toMinutes() <= rhs.toMinutes()
}
func == (lhs:Time, rhs:Time) -> Bool
{
    return lhs.toMinutes() == rhs.toMinutes()
}
