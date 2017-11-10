//
//  Constants.swift
//
//  Created by Vicente Caycedo on 6/10/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Custom colors that are used throughout the app.
*/
enum Colors
{
	static let RED = UIColor(red: 230/255, green: 37/255, blue: 48/255, alpha: 1)
	static let GRAY = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.52)
	static let PINK = UIColor(red: 255/255, green: 204/255, blue: 204/255, alpha: 1)
	static let GRAY_FILTER = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
}

/**
	Reusable images from Assets used throughout the app.
*/
enum Images
{
	static let imageAdded = UIImage(named: "added_event.png")
	static let imageNotAdded = UIImage(named: "add_event.png")
	
	//For Details View
	static let whiteImageAdded = UIImage(named: "added_event_white.png")
	static let whiteImageNotAdded = UIImage(named: "add_event_white.png")
}

/**
	Layout values, like dimens.xml in Android.
*/
enum Layout
{
	static let MARGIN:CGFloat = 20
	static let TEXT_VERTICAL_SPACING:CGFloat = 2
	static let DATE_SIZE:CGFloat = 64
	static let HOUR_HEIGHT:CGFloat = 50		//distance between each hour in `ScheduleVC`
}

/**
	Font names.
*/
enum Font
{
	static let MEDIUM = "AvenirNext-Medium"
	static let REGULAR = "AvenirNext-Regular"
	static let BOLD = "AvenirNext-DemiBold"
}

/**
	Names for custom notifications. Classes interested in receiving notifications for a particular event should subscribe to the event's corresponding notification. Another class generates notifications for the particular event.
*/
extension Notification.Name
{
    static let reloadData = Notification.Name("reloadData")
    static let reloadSettings = Notification.Name("reloadSettings")
	static let dateChanged = Notification.Name("dateChanged")
}
