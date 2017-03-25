//
//  ScheduleCell.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/24/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func configure(title: String){
        label.text = title
    }
    
}
