//
//  ScheduleCell.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/24/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Displays the hour on the left of `ScheduleVC`.
*/
class ScheduleCell: UITableViewCell
{
    @IBOutlet weak var label: UILabel!
	
	/**
		Set the hour text to display.
	*/
    func configure(title: String)
	{
        label.text = title
    }
}
