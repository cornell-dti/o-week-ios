//
//  DateCell.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 5/5/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Holds data and reference pointers to `View`s for an orientation date button.
	`date`: The date that this object currently represents.
	- seeAlso: `DatePickerController`
*/
class DateCell: UICollectionViewCell
{
	
    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var dayNum: UILabel!
    
    var date: Date?
    static let DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
	
	/**
		Sets the `date` that this cell will represent, and updates the text it is displaying.
		- parameter date: The date that this cell wil represent.
	*/
    func configure(date: Date)
	{
		view.layer.cornerRadius = view.frame.width / 2	//turn the view's background from a square to a circle
        self.date = date
        self.weekDay.text = DateCell.DAYS[UserData.userCalendar.component(.weekday, from: date) - 1] //Index of day is between 1 and 7, subtract 1 to adjust index to 0 - 6
        self.dayNum.text = String(UserData.userCalendar.component(.day, from: date))
    }
    /**
		Selects/deselects the cell and plays the appropriate animation.
		- parameter selected: True if the cell was selected by the user, false if the user just selected some other cell and this cell should be deselected.
	*/
    func selected(_ selected: Bool)
	{
        UIView.animate(withDuration: 0.25){
            if(selected)
            {
                self.view.backgroundColor = UIColor.white
                self.dayNum.textColor = UIColor.black
            }
            else
            {
                self.view.backgroundColor = Colors.RED
                self.dayNum.textColor = UIColor.white
            }
        }
        
    }
    
}
