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
        setButtonImage(UserData.selectedEventsContains(event))
    }
    
    @IBAction func addBttnPressed(_ sender: UIButton) {
        if(UserData.selectedEventsContains(event!)){
            setButtonImage(false)
            UserData.removeFromSelectedEvents(event!)
            LocalNotifications.removeNotification(for: event!)
        } else {
            setButtonImage(true)
            UserData.insertToSelectedEvents(event!)
            LocalNotifications.addNotification(for: event!)
        }
    }
    
    func setButtonImage(_ added: Bool){
        UIView.animate(withDuration: 0.5) {
            self.eventButton.alpha = 0
        }
        if (added){
            self.eventButton.setImage(Constants.Images.imageAdded, for: .normal)
        } else {
            self.eventButton.setImage(Constants.Images.imageNotAdded, for: .normal)
        }
        UIView.animate(withDuration: 0.5) {
            self.eventButton.alpha = 1
        }
    }
    
}
