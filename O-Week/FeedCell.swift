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
    
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventEndTime: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventCaption: UILabel!
    
    var added = false
    
    let imageAdded = UIImage(named: "added_event.png")
    let imageNotAdded = UIImage(named: "add_event.png")
    
    
    func configure(title:String, caption:String, startTime:String, endTime: String)
    {
        eventTitle.text = title
        eventCaption.text = caption
        eventStartTime.text = startTime
        eventEndTime.text = endTime
        
        // TODO: fix button image when initialized depending on whether user had previously added event
    }
    
    @IBAction func addBttnPressed(_ sender: UIButton) {
        //TODO: implement button functionality
        if(!added){
            sender.setImage(imageAdded, for: .normal)
            added = true
        } else {
            sender.setImage(imageNotAdded, for: .normal)
            added = false
        }
    }
}
