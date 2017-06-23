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
	private var category:Category?
	private var allEvents = false
	private var requiredEvents = false
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		setDefaultLook()
		label.layer.borderColor = Constants.Colors.GRAY.cgColor
	}
	func configure(category:Category)
	{
		self.category = category
		label.text = category.name
		allEvents = false
		requiredEvents = false
	}
	func configureRequiredEvents()
	{
		label.text = "Show Required Events"
		allEvents = false
		requiredEvents = true
	}
	func configureAllEvents()
	{
		label.text = "Show All Events"
		allEvents = true
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
