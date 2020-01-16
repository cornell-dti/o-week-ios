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
	static let ORDERED:[Colleges] = [.CALS, .AAP, .ArtsAndSciences, .Engineering, .JohnsonB, .JohnsonH, .ILR, .HumanEc]
	
	case CALS = "Agriculture & Life Sciences"
	case AAP = "Architecture, Art, and Planning"
	case ArtsAndSciences = "Arts & Sciences"
	case Engineering = "Engineering"
	case JohnsonB = "SC Johnson College of Business"
    case JohnsonH = "SC Johnson College of Business - Hotel Administration"
	case ILR = "ILR School"
	case HumanEc = "Human Ecology"
	
	/**
		Returns the `Category.pk` value of the category associated with this college. Assumes the database will never change colleges' pk values.
		- returns: `Category.pk`, where the Category is the one for this college.
	*/
	var pk:String {
		switch (self)
		{
		case .CALS:
			return "Agriculture & Life Sciences"
		case .AAP:
			return "Architecture, Art, and Planning"
		case .ArtsAndSciences:
			return "Arts & Sciences"
		case .Engineering:
			return "Engineering"
		case .JohnsonB:
			return "SC Johnson College of Business"
        case .JohnsonH:
            return "SC Johnson College of Business - Hotel Administration"
		case .ILR:
			return "ILR School"
		case .HumanEc:
			return "Human Ecology"
		}
	}
	/**
		The inverse of `pk`.
		- returns: The correct college for the `Category.pk`, or nil if this `Category.pk` does not belong to a college.
	*/
	static func collegeForPk(_ pk:String) -> Colleges?
	{
		switch (pk)
		{
        case "Agriculture & Life Sciences":
			return .CALS
		case "Architecture, Art, and Planning":
			return .AAP
		case "Arts & Sciences":
			return .ArtsAndSciences
		case "Engineering":
			return .Engineering
		case "SC Johnson College of Business":
			return .JohnsonB
        case "SC Johnson College of Business - Hotel Administration":
            return .JohnsonH
		case "ILR School":
			return .ILR
		case "Human Ecology":
			return .HumanEc
		default:
			return nil
		}
	}
}
