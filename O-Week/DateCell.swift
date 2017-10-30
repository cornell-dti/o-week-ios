//
//  DateCell.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 5/5/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit
import PureLayout

/**
	Holds data and reference pointers to `View`s for an orientation date button.
	`date`: The date that this object currently represents.
	- seeAlso: `DatePickerController`
*/
class DateCell: UICollectionViewCell
{
    let weekDay = UILabel.newAutoLayout()
    let dayBackground = UIView.newAutoLayout()
    let dayNum = UILabel.newAutoLayout()
    
    var date: Date?
    static let DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
	
	//must be written since we provided `init()`. Will not be used.
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	/**
		Sets up all subviews of the DateCell.
		|				|
		|	  SUN		|
		|				|
		| 	 /	  \		|
		| 	|  14  |	|
		|	 \	  /		|
		|				|
	*/
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		// StackView to hold everything
		let verticalStack = UIStackView()
		contentView.addSubview(verticalStack)
		verticalStack.axis = .vertical
		verticalStack.alignment = .center
		verticalStack.distribution = .equalSpacing
		verticalStack.spacing = 2.6
		verticalStack.autoAlignAxis(toSuperviewAxis: .horizontal)
		verticalStack.autoAlignAxis(toSuperviewAxis: .vertical)
		
		weekDay.textAlignment = .center
		weekDay.textColor = UIColor.white
		weekDay.font = UIFont(name: Font.MEDIUM, size: 12)
		verticalStack.addArrangedSubview(weekDay)
		
		dayNum.autoSetDimensions(to: CGSize(width: 32, height: 32))
		dayNum.textAlignment = .center
		dayNum.textColor = UIColor.white
		dayNum.font = UIFont(name: Font.MEDIUM, size: 18)
		verticalStack.addArrangedSubview(dayNum)
		
		verticalStack.addSubview(dayBackground)
		verticalStack.sendSubview(toBack: dayBackground)
		dayBackground.autoAlignAxis(.horizontal, toSameAxisOf: dayNum)
		dayBackground.autoAlignAxis(.vertical, toSameAxisOf: dayNum)
		dayBackground.autoMatch(.width, to: .width, of: dayNum)
		dayBackground.autoMatch(.height, to: .height, of: dayNum)
		dayBackground.layer.cornerRadius = 16	//turn the view's background from a square to a circle
	}
	/**
		Sets the `date` that this cell will represent, and updates the text it is displaying.
		- parameter date: The date that this cell wil represent.
	*/
    func configure(date: Date)
	{
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
            if (selected)
            {
                self.dayBackground.backgroundColor = UIColor.white
                self.dayNum.textColor = UIColor.black
            }
            else
            {
                self.dayBackground.backgroundColor = UIColor.clear
                self.dayNum.textColor = UIColor.white
            }
        }
    }
}
