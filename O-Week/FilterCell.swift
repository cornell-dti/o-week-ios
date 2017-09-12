//
//  FilterCell.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/12/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	A cell in the table of `FilterVC` that the user can select.

	`category`: The category that this cell represents. Is nil if it's a special category.
	`requiredEvents`: True if this cell represents the cell for "show all required events," false otherwise. If this is false and `category` is nil, then this cell represents "show all events."
*/
class FilterCell: UITableViewCell
{
    @IBOutlet weak var label: UILabel!
	private(set) var category:Category?
	private(set) var requiredEvents = false
	
	/**
		Set up the style of this cell (once).
	*/
	override func awakeFromNib()
	{
		super.awakeFromNib()
		setDefaultLook()
		label.layer.borderColor = Colors.GRAY.cgColor
	}
	/**
		Sets cell to unselected state.
	*/
	private func setDefaultLook()
	{
		label.backgroundColor = UIColor.white
		label.textColor = Colors.GRAY_FILTER
		label.layer.borderWidth = 1
	}
	
	/**
		Make this cell be the button for the given category.
		- parameter category: The category that this cell will represent.
	*/
	func configure(category:Category)
	{
		self.category = category
		label.text = category.name
		requiredEvents = false
	}
	/**
		Make this cell be the button for "Show Required Events," which is not a `Category`.
	*/
	func configureRequiredEvents()
	{
		category = nil
		label.text = "Show Required Events"
		requiredEvents = true
	}
	/**
		Make this cell be the button for "Show All Events," which is not a `Category`.
	*/
	func configureAllEvents()
	{
		category = nil
		label.text = "Show All Events"
		requiredEvents = false
	}
	/**
		Selects/deselects this cell and change its look.
		- parameter selected: Whether this cell is selected.
	*/
	func selected(_ selected:Bool)
	{
		if (selected)
		{
			label.backgroundColor = Colors.RED
			label.textColor = UIColor.white
			label.layer.borderWidth = 0
		}
		else
		{
			setDefaultLook()
		}
	}
	
	
}
