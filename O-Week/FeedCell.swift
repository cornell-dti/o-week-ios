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
	@IBOutlet weak var requiredText: UITextField!
	@IBOutlet weak var categoryRequired: UILabel!
    
    var event:Event!
	
	override func awakeFromNib()
	{
		requiredText.layer.cornerRadius = requiredText.frame.width / 2
	}
    func configure(event:Event)
	{
        self.event = event
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventStartTime.text = event.startTime.description
        eventEndTime.text = event.endTime.description
        setButtonImage(UserData.selectedEventsContains(event))
		
		requiredText.isHidden = !event.required
		
		if (event.categoryRequired)
		{
			categoryRequired.text = UserData.categoryFor(event.category)?.name
			categoryRequired.isHidden = false
		}
		else
		{
			categoryRequired.isHidden = true
		}
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
    
    private func setButtonImage(_ added: Bool)
    {
        UIView.animate(withDuration: 0.5) {
            self.eventButton.alpha = 0
            let image = added ? Constants.Images.imageAdded : Constants.Images.imageNotAdded
            self.eventButton.setImage(image, for: .normal)
            self.eventButton.alpha = 1
        }
    }
    
}
