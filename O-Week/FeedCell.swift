//
//  FeedCell.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/17/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class FeedCell:UITableViewCell
{
    
    //TODO: Connect button
    
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventEndTime: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventCaption: UILabel!
    
    
    func configure(title:String, caption:String, startTime:String, endTime: String)
    {
        eventTitle.text = title
        eventCaption.text = caption
        eventStartTime.text = startTime
        eventEndTime.text = endTime
    }
}
