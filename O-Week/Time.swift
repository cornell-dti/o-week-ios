//
//  Time.swift
//  O-Week
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import Foundation

/**
	Helper class to hold an hour and a minute. `Date` is too bloated to use in Swift, thus this custom alternative. Designed to be immutable.
*/
struct Time:Comparable, Hashable, CustomStringConvertible
{
    let hour:Int
    let minute:Int
	
	/**
		Formats the object into hh:MM AM/PM format. Takes into consideration when hour == 0 but should be displayed as 12 AM.
	*/
    var description:String
    {
        //from 24HR format to 12HR format
        if (hour > 12)
        {
            return String(format: "%02d:%02d PM", hour - 12, minute)
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
            return String(format: "%02d:%02d AM", hour, minute)
        }
    }
	/**
		Formats the object into hh AM/PM format, ignoring the minutes. Also takes into consideration special cases when hour == 0 or 12.
	*/
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
	
	/**
		Create a `Time` object that holds the current hour and minute. Since `Time` is immutable, this will obviously not accurately represent current time as time goes on.
	*/
    init()
    {
        let date = Date()
        let components = NSCalendar.current.dateComponents([.hour, .minute], from: date)
        self.hour = components.hour!
        self.minute = components.minute!
    }
	/**
		Create a time object with the given parameters.
		
		- parameter:
			- hour: Military hour. Range = [0, 24)
			- minute: Range = [0, 60)
	*/
    init(hour:Int, minute:Int)
    {
        self.hour = hour
        self.minute = minute
    }
	/**
		Create a time object for which minutes = 0
		
		- parameter hour: Military hour. Range = [0, 24)
	*/
    init(hour:Int)
    {
        self.hour = hour
        minute = 0
    }
	/**
		Create a time object from the given string. Expected format is "hh:MM:ss", where hours are military hours. The seconds field is discarded.
		
		- important: A string given in an unexpected format will crash the app.
		
		- parameter timeString: String in format "hh:MM:ss"
		- returns: New Time object.
	*/
    static func fromString(_ timeString:String) -> Time
    {
        let hourAndMin = timeString.components(separatedBy: ":")    //"10", "00"
        let hour = Int(hourAndMin[0])
        let min = Int(hourAndMin[1])
        return Time(hour: hour!, minute: min!)
    }
	/**
		Returns the number of minutes from the beginning of the day to this time. For example, 1:15 AM = 75 minutes. Useful for calculating differences.
		- returns: See description.
	*/
    func toMinutes() -> Int
    {
        return hour * 60 + minute;
    }
	/**
		Creates a Time object from the given number of minutes, counting each hour as 60 minutes.
		- returns: Time object.
	*/
    static func fromMinutes(_ minutes:Int) -> Time
    {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return Time(hour: hours, minute: remainingMinutes)
    }
	/**
		Creates a time object by adding a number of minutes to a given time object. The given object is not mutated.
		- parameters:
			- startTime: Time to add to
			- minutesToAdd: Minutes to add to time. Can be negative for subtraction.
		- returns: Time object as result of addition. May produce strange objects if total minutes is negative or exceeds the number of minutes in a 24 hour day.
	*/
    static func add(startTime:Time, minutesToAdd:Int) -> Time
    {
        var timeInMinutes = startTime.toMinutes()
        timeInMinutes += minutesToAdd
        return Time.fromMinutes(timeInMinutes)
    }
	/**
		Returns the number of minutes from startTime to endTime. Can be negative if endTime is earlier than startTime.
		- parameters:
			- startTime: Time to subtract
			- endTime: Time to subtract from.
		- returns: Number of minutes elapsed.
	*/
    static func length(startTime:Time, endTime:Time) -> Int
    {
		return endTime.toMinutes() - startTime.toMinutes()
    }
}

//All following comparison methods use `toMinutes()`
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
