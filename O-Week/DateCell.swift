//
//  DateCell.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 5/5/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class DateCell: UICollectionViewCell {
    
    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var dayNum: UILabel!
    
    var date: Date?
    let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    func configure(date: Date)
	{
        view.layer.cornerRadius = view.frame.width / 2
        self.date = date
        self.weekDay.text = days[UserData.userCalendar.component(.weekday, from: date) - 1] //Index of day is between 1 and 7, subtract 1 to adjust index to 0 - 6
        self.dayNum.text = String(UserData.userCalendar.component(.day, from: date))
    }
    
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
                self.view.backgroundColor = Constants.Colors.RED
                self.dayNum.textColor = UIColor.white
            }
        }
        
    }
    
}
