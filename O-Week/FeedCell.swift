//
//  FeedCell.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/17/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Holds data and reference pointers to `View`s for an `Event`.
	`event`: The event that this object currently represents.
	- seeAlso: `FeedVC`
*/
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
	
	/**
		Turns the background of "RQ" to a circle.
	*/
	override func awakeFromNib()
	{
		requiredText.layer.cornerRadius = requiredText.frame.width / 2
	}
	/**
		Sets the current event to display.
		- parameter event: The `Event` that this cell will represent.
	*/
    func configure(event:Event)
	{
        self.event = event
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventStartTime.text = event.startTime.description
        eventEndTime.text = event.endTime.description
        setButtonImage(UserData.selectedEventsContains(event))
		
		requiredText.isHidden = !(event.required || event.categoryRequired)
		
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
	
	/**
		'+' button pressed. Add/remove the event from selected events.
		- parameter sender: Button that was pressed.
	*/
    @IBAction func addBttnPressed(_ sender: UIButton)
	{
        if (UserData.selectedEventsContains(event!))
		{
            setButtonImage(false)
            UserData.removeFromSelectedEvents(event!)
            LocalNotifications.removeNotification(for: event!.pk)
        }
		else
		{
            setButtonImage(true)
            UserData.insertToSelectedEvents(event!)
            LocalNotifications.createNotification(for: event!)
        }
    }
	
	/**
		Set the '+' button to an image that represents whether the event is selected.
		- parameter added: True if the event should be displayed as "selected".
	*/
    private func setButtonImage(_ added: Bool)
    {
        UIView.animate(withDuration: 0.5) {
            self.eventButton.alpha = 0
            let image = added ? Images.imageAdded : Images.imageNotAdded
            self.eventButton.setImage(image, for: .normal)
            self.eventButton.alpha = 1
        }
    }
    
}
