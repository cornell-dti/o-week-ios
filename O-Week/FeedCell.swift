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
    
    func configure(event:Event)
    {
        self.event = event
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventStartTime.text = event.startTime.description
        eventEndTime.text = event.endTime.description
        setButtonAdded(event.added)
        
        //Setting all events to added for testing
        //event.added = true
        //setButtonAdded(true)
        
    }
    
    @IBAction func addBttnPressed(_ sender: UIButton)
    {
        event.added = !event.added
        setButtonAdded(event.added)
    }
    
    private func setButtonAdded(_ added:Bool)
    {
        if (added){
            eventButton.setImage(Image.imageAdded, for: .normal)
            UserData.selectedEvents.insert(event)
        } else {
            eventButton.setImage(Image.imageNotAdded, for: .normal)
            UserData.selectedEvents.remove(event)
        }
    }

}
