//
//  DetailsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/13/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventCaption: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var add_button: UIButton!
    
    var event: Event?
    var changed = false
    
    override func viewDidLoad()
	{
        super.viewDidLoad()
        configure(event: self.event!)
    }
    
    override func viewWillDisappear(_ animated: Bool)
	{
        if (changed)
		{
            NotificationCenter.default.post(name: .reloadData, object: nil)
        }
    }
    
    func configure(event:Event)
    {
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventDescription.text = event.description
        startTime.text = event.startTime.description
        endTime.text = event.endTime.description
        setButtonImage(UserData.selectedEventsContains(event))
		Internet.getImageFor(event, imageView: eventImage)
    }
    
    @IBAction func add_button_pressed(_ sender: UIButton)
	{
        if(UserData.selectedEventsContains(event!))
		{
            setButtonImage(false)
            UserData.removeFromSelectedEvents(event!)
            LocalNotifications.removeNotification(for: event!)
        }
		else
		{
            setButtonImage(true)
            UserData.insertToSelectedEvents(event!)
            LocalNotifications.addNotification(for: event!)
        }
        changed = true
        
    }
    
    private func setButtonImage(_ added:Bool)
	{
        UIView.animate(withDuration: 0.5) {
            self.add_button.alpha = 0
        }
        if (added)
		{
            add_button.setImage(Constants.Images.whiteImageAdded, for: .normal)
        }
		else
		{
            add_button.setImage(Constants.Images.whiteImageNotAdded, for: .normal)
        }
        UIView.animate(withDuration: 0.5) {
            self.add_button.alpha = 1
        }
    }
}
