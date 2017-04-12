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
    
    var added = false
    var event:Event!
    
    static let imageAdded = UIImage(named: "added_event.png")
    static let imageNotAdded = UIImage(named: "add_event.png")
    
    static var selectedEvents:Set<Event> = Set()
    
    
    func configure(event:Event)
    {
        self.event = event
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventStartTime.text = event.startTime.description
        eventEndTime.text = event.endTime.description
        //setButtonOn(FeedCell.selectedEvents.contains(event))
        setButtonOn(true)
        
        // TODO: fix button image when initialized depending on whether user had previously added event
    }
    
    @IBAction func addBttnPressed(_ sender: UIButton)
    {
        setButtonOn(!added)
    }
    private func setButtonOn(_ on:Bool)
    {
        if (on)
        {
            eventButton.setImage(FeedCell.imageAdded, for: .normal)
            added = true
            FeedCell.selectedEvents.insert(event)
        }
        else
        {
            eventButton.setImage(FeedCell.imageNotAdded, for: .normal)
            added = false
            FeedCell.selectedEvents.remove(event)
        }
    }
}
