//
//  Student.swift
//  O-Week
//
//  Created by David Chu on 2017/11/26.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import Foundation

/**
	Predefined list of student types and their associated strings.
	`ORDERED`: An alphabetically ordered list of all enums cases. Should change every time a case is added/removed.

	- see: `Colleges`
*/
enum Student:String, HasPK
{
	static let ORDERED:[Student] = [.Transfer]
	case Transfer = "Transfer"
    case Freshmen = "Freshmen"
	
	/**
		Returns the `Category.pk` value of the category associated with this student type. Assumes the database will never change student types' pk values.
		- returns: `Category.pk`, where the Category is the one for this student type.
	*/
	var pk:String {
        switch self {
        case .Transfer:
            return "B8AE27DD-DCD0-EF66-FC3B05EB37B392D7"
        case .Freshmen:
            return "B8AFD836-CF90-1614-C4C83BEF191C9C07"
        }
		
	}
	/**
		The inverse of `pk`.
		- returns: The correct student type for the `Category.pk`, or nil if this `Category.pk` does not belong to a student type.
	*/
	static func studentForPk(_ pk:String) -> Student?
	{
		if (pk == "B8AE27DD-DCD0-EF66-FC3B05EB37B392D7")
		{
			return .Transfer
		}
        else if pk == "B8AFD836-CF90-1614-C4C83BEF191C9C07" {
            return .Freshmen
        }
		return nil
	}
}
