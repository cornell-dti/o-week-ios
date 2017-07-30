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
        static let RED = UIColor(red: 229/255, green: 43/255, blue: 54/255, alpha: 1)
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
    
}

extension Notification.Name {
    static let reloadData = Notification.Name("reloadData")
    static let reloadSettings = Notification.Name("reloadSettings")
}
