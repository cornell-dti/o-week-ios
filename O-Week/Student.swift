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
	
	/**
		Returns the `Category.pk` value of the category associated with this student type. Assumes the database will never change student types' pk values.
		- returns: `Category.pk`, where the Category is the one for this student type.
	*/
	var pk:Int {
		return 14
	}
	/**
		The inverse of `pk`.
		- returns: The correct student type for the `Category.pk`, or nil if this `Category.pk` does not belong to a student type.
	*/
	static func studentForPk(_ pk:Int) -> Student?
	{
		if (pk == 14)
		{
			return .Transfer
		}
		return nil
	}
}
