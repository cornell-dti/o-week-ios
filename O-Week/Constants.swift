//
//  Constants.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/10/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation
import UIKit

struct Constants
{
    
    private init(){}
    
    //  Holds static instances of app's colors
    struct Colors
    {
        static let RED = UIColor(red: 215/255, green: 35/255, blue: 53/255, alpha: 1)
        static let GRAY = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.52)
        static let PINK = UIColor(red: 255/255, green: 204/255, blue: 204/255, alpha: 1)
        static let GRAY_FILTER = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        
        private init(){}
    }
    
    //  Holds static instances of app's button images
    struct Images
    {
        static let imageAdded = UIImage(named: "added_event.png")
        static let imageNotAdded = UIImage(named: "add_event.png")
        
        //For Details View
        static let whiteImageAdded = UIImage(named: "added_event_white.png")
        static let whiteImageNotAdded = UIImage(named: "add_event_white.png")
        
        private init(){}
    }
    
    enum Settings: String {
        case receiveRemindersFor = "Receive reminders for..."
        case notifyMe = "Notify me..."
    }
    
}

extension Notification.Name {
    static let reload = Notification.Name("reload")
    static let reloadSettings = Notification.Name("reloadSettings")
}
