//
//  Notifications.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/13/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation
import UserNotifications

struct Notifications {
    
    static let center = UNUserNotificationCenter.current()
    static let options: UNAuthorizationOptions = [.alert, .sound, .badge];
    
    static func requestPermissionForNotificationsIfNeeded(){
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                center.requestAuthorization(options: options) {
                    (granted, error) in
                    if !granted {
                        print("Notification permissions error")
                    }
                }
            }
        }
    }
    
}
