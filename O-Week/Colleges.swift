//
//  Colleges.swift
//  O-Week
//
//  Created by David Chu on 2017/11/25.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import Foundation

/**
	Predefined list of colleges and their names.
*/
enum Colleges:String
{
	static let ORDERED:[Colleges] = [.CALS, .AEM, .AAP, .ArtsAndSciences, .Engineering, .Hotel, .ILR, .HumanEc]
	
	case CALS = "Agriculture and Life Sciences"
	case AEM = "Applied Economics & Management"
	case AAP = "Architecture, Art, and Planning"
	case ArtsAndSciences = "Arts & Sciences"
	case Engineering = "Engineering"
	case Hotel = "Hotel Administration"
	case ILR = "Industrial Labor Relations"
	case HumanEc = "Human Ecology"
	
	func pkForCollege() -> Int
	{
		//TODO match to database pk
		return 0
	}
}
