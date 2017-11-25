//
//  UserPreferences.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/14/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import Foundation

/**
	Provides an easy way to read/write user preferences in which they pick an option from a list inside settings. Whenever a new saved field is to be added, do the following:
	1. Add a case associated with its respective key. Like: `case NotifyTime = "Notify me..."`
	2. Add its options under `Option`
	3. Put those options into a list under `Option`
	4. Put the default option under `DEFAULT` with the key
	5. Put the options list under `OPTIONS` with the key

	`NotifyTime`: What time before an event starts should the notification be sent.

	`DEFAULT`: Dictionary of default values for the given key. These values are used until the user first chooses an option.
	`OPTIONS`: The options the user has to choose from for any specific preference.
*/
enum ListPreference:String
{
	case NotifyTime = "Notify me…"
	
	static let DEFAULT:[ListPreference:Option] = [.NotifyTime:.OneHourBefore]
	static let OPTIONS:[ListPreference:[Option]] = [.NotifyTime:Option.NotifyTimeOption]
	
	enum Option:String
	{
		//NotifyTime Option
		case AtTimeOfEvent = "At time of event"
		case OneHourBefore = "1 hour before"
		case TwoHoursBefore = "2 hours before"
		case FiveHoursBefore = "5 hours before"
		case OneDayBefore = "1 day before"
		static let NotifyTimeOption:[Option] = [.AtTimeOfEvent, .OneHourBefore, .TwoHoursBefore, .FiveHoursBefore, .OneDayBefore]
		
		/**
		Returns how many milliseconds ahead of time we should notify the user of an event.
		- returns: Interval (that should be added to event's start time) or nil if the setting cannot be directly converted into a time difference.
		*/
		func timeInterval() -> TimeInterval?
		{
			switch self
			{
			case .AtTimeOfEvent:
				return TimeInterval()
			case .OneHourBefore:
				return TimeInterval(-3600)
			case .TwoHoursBefore:
				return TimeInterval(-7200)
			case .FiveHoursBefore:
				return TimeInterval(-18000)
			case .OneDayBefore:
				return TimeInterval(-86400)
			}
		}
	}
	
	/**
		Retrieves the saved option for the key (`self`), wrapping it inside one of the enums declared above in `Option`, using the default value in `DEFAULT` if these is no saved option.
		- important: Will crash if `DEFAULT` does not contain an entry for key `self`.
		- returns: Saved value wrapped as `Option`.
	*/
	func get() -> Option
	{
		if let savedValue = UserDefaults.standard.string(forKey: rawValue)
		{
			return Option(rawValue: savedValue) ?? ListPreference.DEFAULT[self]!
		}
		return ListPreference.DEFAULT[self]!
	}
	/**
		Saves `option` in the key `self`.
		- parameter option: The option the user has selected and wants to save.
	*/
	func set(_ option:Option)
	{
		UserDefaults.standard.set(option.rawValue, forKey: rawValue)
	}
}
/**
	Provides an easy way to read/write user preferences that are either true or false. Whenever a new saved field is to be added, do the following:
	1. Add a case associated with its respective key. Like: `case NotifyTime = "Notify me..."`
	2. Put the default option under `DEFAULT` with the key

	`Reminder`: Whether user should be notified of events.

	`DEFAULT`: Dictionary of default values for the given key. These values are used until the user first chooses an option.
*/
enum BoolPreference:String
{
	case Reminder = "Reminders"
	static let DEFAULT:[BoolPreference:Bool] = [.Reminder:true]
	
	/**
		Retrieves the saved option for the key (`self`). Retrieves the saved option as an object first (so that it can be nil) as opposed to a boolean, because `bool(forKey:_)` returns `false` if the user has never set, but the default value could be true.
	
		- important: Will crash if `DEFAULT` does not contain an entry for key `self`.
		- returns: Saved value.
	*/
	func isTrue() -> Bool
	{
		return (UserDefaults.standard.object(forKey: rawValue) as? Bool) ?? BoolPreference.DEFAULT[self]!
	}
	/**
		Saves `option` in the key `self`.
		- parameter option: The option the user has selected and wants to save.
	*/
	func set(_ option:Bool)
	{
		UserDefaults.standard.set(option, forKey: rawValue)
	}
}
