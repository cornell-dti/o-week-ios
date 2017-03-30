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
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(event:Event)
    {
        eventTitle.text = event.title
        eventCaption.text = event.caption
        startTime.text = event.startTime.description
        endTime.text = event.endTime.description
    }
}
