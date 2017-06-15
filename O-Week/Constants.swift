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
    
    static let setForSetting = Setting(name: "Set for...", options: ["All my events", "Only required events"])
    static let notifyMeSetting = Setting(name: "Notify me...", options: ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"])
    struct Setting {
        let name: String
        let options: [String]
    }
    
}

extension Notification.Name {
    static let reload = Notification.Name("reload")
    static let reloadSettings = Notification.Name("reloadSettings")
}
