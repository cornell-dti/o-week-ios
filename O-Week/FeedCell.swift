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
    @IBOutlet weak var eventButton: UIButton!
    
    var event:Event!
    
    func configure(event:Event) {
        self.event = event
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventStartTime.text = event.startTime.description
        eventEndTime.text = event.endTime.description
        setButtonImage(UserData.selectedEvents.contains(self.event))
    }
    
    @IBAction func addBttnPressed(_ sender: UIButton) {
        if(UserData.selectedEvents.contains(event!)){
            setButtonImage(false)
            UserData.selectedEvents.remove(event!)
        } else {
            setButtonImage(true)
            UserData.selectedEvents.insert(event!)
        }
    }
    
    func setButtonImage(_ added: Bool){
        if (added){
            eventButton.setImage(Image.imageAdded, for: .normal)
        } else {
            eventButton.setImage(Image.imageNotAdded, for: .normal)
        }
    }
    
}
