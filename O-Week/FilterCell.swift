//
//  FilterCell.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/12/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell
{
    @IBOutlet weak var label: UILabel!
	private(set) var category:Category?
	private(set) var requiredEvents = false
	
	override func awakeFromNib()
	{
		super.awakeFromNib()
		setDefaultLook()
		label.layer.borderColor = Constants.Colors.GRAY.cgColor
	}
	func configure(category:Category)
	{
		self.category = category
		label.text = category.name
		requiredEvents = false
	}
	func configureRequiredEvents()
	{
		category = nil
		label.text = "Show Required Events"
		requiredEvents = true
	}
	func configureAllEvents()
	{
		category = nil
		label.text = "Show All Events"
		requiredEvents = false
	}
	
	func selected(_ selected:Bool)
	{
		if (selected)
		{
			label.backgroundColor = Constants.Colors.RED
			label.textColor = UIColor.white
			label.layer.borderWidth = 0
		}
		else
		{
			setDefaultLook()
		}
	}
	
	private func setDefaultLook()
	{
		label.backgroundColor = UIColor.white
		label.textColor = Constants.Colors.GRAY_FILTER
		label.layer.borderWidth = 1
	}
}
