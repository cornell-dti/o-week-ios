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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(event: self.event!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(changed){
            NotificationCenter.default.post(name: .reload, object: nil)
        }
    }
    
    func configure(event:Event)
    {
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventDescription.text = event.description
        startTime.text = event.startTime.description
        endTime.text = event.endTime.description
        setButtonImage(UserData.selectedEvents.contains(event))
        Internet.imageFrom("https://upload.wikimedia.org/wikipedia/commons/3/34/Cornell_University%2C_Ho_Plaza_and_Sage_Hall.jpg", imageView: eventImage)
    }
    
    @IBAction func add_button_pressed(_ sender: UIButton) {
        if(UserData.selectedEvents.contains(event!)){
            setButtonImage(false)
            UserData.selectedEvents.remove(event!)
        } else {
            setButtonImage(true)
            UserData.selectedEvents.insert(event!)
        }
        changed = true
        
    }
    
    private func setButtonImage(_ added:Bool) {
        if (added){
            add_button.setImage(Image.imageAddedW, for: .normal)
        } else {
            add_button.setImage(Image.imageNotAddedW, for: .normal)
        }
    }
}
