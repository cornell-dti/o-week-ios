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
    @IBOutlet weak var date: UILabel!
    
    let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    func configure(date: Date){
        view.layer.cornerRadius = view.frame.width / 2
        self.weekDay.text = days[UserData.userCalendar.component(.weekday, from: date) - 1] //Index of day is between 1 and 7, subtract 1 to adjust index to 0 - 6
        self.date.text = String(UserData.userCalendar.component(.day, from: date))
    }
    
    func selected(_ selected: Bool){
        if(selected){
            view.backgroundColor = UIColor.white
            date.textColor = UIColor.black
        } else {
            view.backgroundColor = Color.RED
            date.textColor = UIColor.white
        }
    }
    
}
