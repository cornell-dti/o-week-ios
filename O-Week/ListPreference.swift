//
//  UserPreferences.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/14/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import Foundation

enum ListPreference:String
{
	case Notify = "Set for..."
	case NotifyTime = "Notify me..."
	
	static let DEFAULT:[ListPreference:Option] = [.Notify:.AllMyEvents, .NotifyTime:.OneHourBefore]
	static let OPTIONS:[ListPreference:[Option]] = [.Notify:Option.NotifyOption, .NotifyTime:Option.NotifyTimeOption]
	
	enum Option:String
	{
		//Notify Option
		case AllMyEvents = "All my events"
		case OnlyRequiredEvents = "Only required events"
		case None = "None"
		static let NotifyOption:[Option] = [.AllMyEvents, .OnlyRequiredEvents, .None]
		
		//NotifyTime Option
		case AtTimeOfEvent = "At time of event"
		case OneHourBefore = "1 hour before"
		case TwoHoursBefore = "2 hours before"
		case FiveHoursBefore = "5 hours before"
		case MorningOf = "Morning of (7 am)"
		case OneDayBefore = "1 day before"
		static let NotifyTimeOption:[Option] = [.AtTimeOfEvent, .OneHourBefore, .TwoHoursBefore, .FiveHoursBefore, .MorningOf, .OneDayBefore]
		
		/**
		Returns how many milliseconds ahead of time we should notify the user of an event.
		- returns: Interval (that should be added to event's start time) or nil if the setting cannot be directly converted into a time difference.
		*/
		func timeInterval() -> TimeInterval?
		{
			switch self
			{
			case .AtTimeOfEvent:
				return TimeInterval(0)
			case .OneHourBefore:
				return TimeInterval(-3600)
			case .TwoHoursBefore:
				return TimeInterval(-7200)
			case .FiveHoursBefore:
				return TimeInterval(-18000)
			case .OneDayBefore:
				return TimeInterval(-86400)
			default:
				return nil
			}
		}
	}
	
	func get() -> Option
	{
		if let savedValue = UserDefaults.standard.string(forKey: rawValue)
		{
			return Option(rawValue: savedValue) ?? ListPreference.DEFAULT[self]!
		}
		return ListPreference.DEFAULT[self]!
	}
	func set(_ option:Option)
	{
		UserDefaults.standard.set(option.rawValue, forKey: rawValue)
	}
}
