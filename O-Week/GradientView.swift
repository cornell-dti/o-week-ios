//
//  GradientView.swift
//  O-Week
//
//  Created by David Chu on 2017/11/24.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

/**
	A view that displays a gradient as its background.
	`gradientSet`: True if `setGradient(colors, orientation)` has been called before. Then the gradient isn't re-inserted into the view's layers.
*/
class GradientView:UIView
{
	let gradient = CAGradientLayer()
	var gradientSet = false
	
	/**
		Sets the [start color, end color] and the orientation of the gradient.
		- parameters:
			- colors: An array of colors in the gradient. Undefined if length != 2.
			- orientation: The direction the gradient will be painted in.
	*/
	func setGradient(colors:[CGColor], orientation:GradientOrientation)
	{
		gradient.colors = colors
		switch (orientation)
		{
		case .leftToRight:
			gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
			gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
		case .topToBottom:
			gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
			gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
		}
		
		if (!gradientSet)
		{
			layer.insertSublayer(gradient, at: 0)
			gradientSet = true
		}
	}
	/**
		Ensure that the layer's frame is synchronized with the view's bounds, so autolayout on the view translates to the gradient.
	*/
	override var bounds: CGRect {
		didSet {
			gradient.frame = bounds
		}
	}
}
/**
	The directions the gradient can be painted in.
*/
enum GradientOrientation
{
	case leftToRight, topToBottom
}
