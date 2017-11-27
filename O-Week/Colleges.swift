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
	`ORDERED`: An alphabetically ordered list of all enums cases. Should change every time a case is added/removed.
*/
enum Colleges:String, HasPK
{
	static let ORDERED:[Colleges] = [.CALS, .AAP, .ArtsAndSciences, .Engineering, .Johnson, .ILR, .HumanEc]
	
	case CALS = "Agriculture and Life Sciences"
	case AAP = "Architecture, Art, and Planning"
	case ArtsAndSciences = "Arts & Sciences"
	case Engineering = "Engineering"
	case Johnson = "Johnson School of Business"
	case ILR = "Industrial Labor Relations"
	case HumanEc = "Human Ecology"
	
	/**
		Returns the `Category.pk` value of the category associated with this college. Assumes the database will never change colleges' pk values.
		- returns: `Category.pk`, where the Category is the one for this college.
	*/
	var pk:Int {
		switch (self)
		{
		case .CALS:
			return 7
		case .AAP:
			return 13
		case .ArtsAndSciences:
			return 8
		case .Engineering:
			return 9
		case .Johnson:
			return 12
		case .ILR:
			return 11
		case .HumanEc:
			return 10
		}
	}
	/**
		The inverse of `pk`.
		- returns: The correct college for the `Category.pk`, or nil if this `Category.pk` does not belong to a college.
	*/
	static func collegeForPk(_ pk:Int) -> Colleges?
	{
		switch (pk)
		{
		case 7:
			return .CALS
		case 13:
			return .AAP
		case 8:
			return .ArtsAndSciences
		case 9:
			return .Engineering
		case 12:
			return .Johnson
		case 11:
			return .ILR
		case 10:
			return .HumanEc
		default:
			return nil
		}
	}
}
