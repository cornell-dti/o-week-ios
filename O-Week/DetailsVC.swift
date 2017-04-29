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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(event: self.event!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Updating parent view (My schedule or feed) in case the event was added or removed
        if let parentVC = navigationController?.viewControllers.last as? ScheduleVC {
            parentVC.updateSchedule()
        } else if let parentVC = navigationController?.viewControllers.last as? FeedVC {
            parentVC.updateFeed()
        }
    }
    
    func configure(event:Event)
    {
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventDescription.text = event.description
        startTime.text = event.startTime.description
        endTime.text = event.endTime.description
        Internet.imageFrom("https://upload.wikimedia.org/wikipedia/commons/3/34/Cornell_University%2C_Ho_Plaza_and_Sage_Hall.jpg", imageView: eventImage)
        setButtonAdded(event.added)
    }
    
    @IBAction func add_button_pressed(_ sender: UIButton) {
        event!.added = !event!.added
        setButtonAdded(event!.added)
    }
    
    private func setButtonAdded(_ added:Bool)
    {
        if (added){
            add_button.setImage(Image.imageAddedW, for: .normal)
            UserData.selectedEvents.insert(event!)
        } else {
            add_button.setImage(Image.imageNotAddedW, for: .normal)
            UserData.selectedEvents.remove(event!)
        }
    }
}
