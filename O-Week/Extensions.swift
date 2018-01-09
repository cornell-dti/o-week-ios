//
//  Extensions.swift
//  O-Week
//
//  Created by David Chu on 2017/11/24.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

extension UILabel
{
	/**
		Returns the number of lines this UILabel will take up with the text and font it currently has.
		Assumes that `font` and `text` have been set.
		- parameter textWidth: The width of the UILabel. This is required because `frame.width` may be inaccurate; the UILabel, if created with autolayout, will not have an accurate size.
		- returns: The number of lines that the text will take up.
	*/
	func visibleNumberOfLines(textWidth: CGFloat) -> Int
	{
		let heightForCurrentText = height(textWidth: textWidth, string: text!)
		return Int(heightForCurrentText / heightForSingleLine(textWidth: textWidth))
	}
	/**
		Returns the height of a single line of text.
		Assumes that `font` has been set.
		- parameter textWidth: The width of the UILabel. This is required because `frame.width` may be inaccurate; the UILabel, if created with autolayout, will not have an accurate size.
		- returns: The height of a single line of text.
	*/
	func heightForSingleLine(textWidth: CGFloat) -> CGFloat
	{
		return height(textWidth: textWidth, string: "A")
	}
	/**
		Returns the height that a string is expected take up with the current font and the given textWidth.
		Assumes that `font` has been set.
		- parameters:
			- textWidth: The width of the UILabel. This is required because `frame.width` may be inaccurate; the UILabel, if created with autolayout, will not have an accurate size.
			- string: The string whose height should be calculated.
		- returns: The height the string will take up.
	*/
	func height(textWidth:CGFloat, string:String) -> CGFloat
	{
		let drawingContext = NSStringDrawingContext()
		let textSize = CGSize(width: textWidth, height: .greatestFiniteMagnitude)
		let realSize = NSString(string: string).boundingRect(with: textSize, options: .usesLineFragmentOrigin, attributes: [.font:font], context: drawingContext)
		return realSize.height
	}
}
