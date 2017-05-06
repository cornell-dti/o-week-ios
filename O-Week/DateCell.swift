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
