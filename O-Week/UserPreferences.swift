//
//  UserPreferences.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/14/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation

struct UserPreferences {
    
    private init(){}
    
    // Notification Settings
    static var setForSetting = NotificationSetting(name: "Set for...", options: ["All my events", "Only required events"])
    static var notifyMeSetting = NotificationSetting(name: "Notify me...", options: ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"])

    struct NotificationSetting {
        let name: String
        let options: [String]
        var chosen: String? {
            get {
                return UserDefaults.standard.string(forKey: name)
            }
            set {
                if newValue == nil {
                    UserDefaults.standard.removeObject(forKey: name)
                } else {
                    UserDefaults.standard.set(newValue, forKey: name)
                }
            }
        }
    }
    
}
