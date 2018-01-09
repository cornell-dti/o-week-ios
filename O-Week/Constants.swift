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
	static let RED = UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 1)
	static let BRIGHT_RED = UIColor(red: 215/255, green: 35/255, blue: 53/255, alpha: 1)
	static let GRAY = UIColor(red: 229/255, green: 229/255, blue:229/255, alpha: 1)
	static let LIGHT_GRAY = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
	static let PINK = UIColor(red: 255/255, green: 204/255, blue: 204/255, alpha: 1)
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
	static let HOUR_HEIGHT:CGFloat = 84		//distance between each hour in `ScheduleVC`
	static let FEED_CELL_HEIGHT:CGFloat = 80
}

/**
	Font names.
*/
enum Font
{
	static let MEDIUM = "AvenirNext-Medium"
	static let REGULAR = "AvenirNext-Regular"
	static let DEMIBOLD = "AvenirNext-DemiBold"
	static let BOLD = "AvenirNext-Bold"
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
