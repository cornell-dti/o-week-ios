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
	
	case CALS = "Agriculture and Life Sciences"
	case AAP = "Architecture, Art, and Planning"
	case ArtsAndSciences = "Arts & Sciences"
	case Engineering = "Engineering"
	case JohnsonB = "Johnson School of Business"
    case JohnsonH = "Johnson School of Hotel Management"
	case ILR = "Industrial Labor Relations"
	case HumanEc = "Human Ecology"
	
	/**
		Returns the `Category.pk` value of the category associated with this college. Assumes the database will never change colleges' pk values.
		- returns: `Category.pk`, where the Category is the one for this college.
	*/
	var pk:String {
		switch (self)
		{
		case .CALS:
			return "8D0BC52D-C504-D514-F334BEB4E18FF455"
		case .AAP:
			return "8D0F380C-047E-8FD3-CDA449EB7C41A466"
		case .ArtsAndSciences:
			return "8D0D75B3-BE48-48D8-DF46CC38682879C3"
		case .Engineering:
			return "8D11CBA4-D6D3-7FDB-17ECC36ACBED42A5"
		case .JohnsonB:
			return "3D51CFD6-A23C-EF4E-A6DF0F01930ACB62"
        case .JohnsonH:
            return "8D084B16-073C-2EF4-0716B6DB7034C2F6"
		case .ILR:
			return "8D139B03-E3DE-A329-B364603149879B5A"
		case .HumanEc:
			return "8D107B76-AFFE-D1B3-D4D752BCD7ED2265"
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
		case "8D0BC52D-C504-D514-F334BEB4E18FF455":
			return .CALS
		case "8D0F380C-047E-8FD3-CDA449EB7C41A466":
			return .AAP
		case "8D0D75B3-BE48-48D8-DF46CC38682879C3":
			return .ArtsAndSciences
		case "8D11CBA4-D6D3-7FDB-17ECC36ACBED42A5":
			return .Engineering
		case "3D51CFD6-A23C-EF4E-A6DF0F01930ACB62":
			return .JohnsonB
        case "8D084B16-073C-2EF4-0716B6DB7034C2F6":
            return .JohnsonH
		case "8D139B03-E3DE-A329-B364603149879B5A":
			return .ILR
		case "8D107B76-AFFE-D1B3-D4D752BCD7ED2265":
			return .HumanEc
		default:
			return nil
		}
	}
}
