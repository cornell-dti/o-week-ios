//
//  JSONObject.swift
//  O-Week
//
//  Created by David Chu on 2017/6/24.
//  Copyright © 2017年 Cornell D&TI. All rights reserved.
//

import Foundation

/**
	An object that can be created from JSON.
*/
protocol JSONObject
{
	/**
		Creates an instance of this object using JSON read from the database.
		
		- parameter jsonOptional: JSON in dictionary format, with values unknown (look to database API for instructions on how to parse). Can be `nil` if JSON is not in dictionary format, in which case you should talk with whomever manages the database.
		- returns: An instance of the object IFF the JSON was in the correct format and parsed completely successfully; `nil` otherwise.
	*/
	init?(jsonOptional:[String:Any]?)
}
