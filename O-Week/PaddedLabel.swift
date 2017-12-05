//
//  PaddedLabel.swift
//  O-Week
//
//  Created by David Chu on 2017/12/3.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

class PaddedLabel:UILabel
{
	var padding = UIEdgeInsetsMake(0, 0, 0, 0)
	
	override func drawText(in rect: CGRect)
	{
		super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
	}
	override var intrinsicContentSize: CGSize {
		get {
			var contentSize = super.intrinsicContentSize
			contentSize.height += padding.bottom + padding.top
			contentSize.width += padding.left + padding.right
			return contentSize
		}
	}
}
