//
//  LocalNotifications.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/13/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation
import UserNotifications

struct LocalNotifications {
    
    static let center = UNUserNotificationCenter.current()
    static let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    
    static var setForSetting: String? {
        get {
           return UserDefaults.standard.string(forKey: Constants.setForSetting.name)
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: Constants.setForSetting.name)
            }else {
                UserDefaults.standard.set(newValue, forKey: Constants.setForSetting.name)
            }
        }
    }
    static var notifyMeSetting: String? {
        get {
            return UserDefaults.standard.string(forKey: Constants.notifyMeSetting.name)
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: Constants.notifyMeSetting.name)
            }else {
                UserDefaults.standard.set(newValue, forKey: Constants.notifyMeSetting.name)
            }
        }
    }
    
    /*
    /*check permissions*/
    center.getNotificationSettings { (settings) in
      if settings.authorizationStatus != .authorized {
          //FIXME
      }
    }
    /*remove delivered notifications*/
    center.removeAllDeliveredNotifications()
    */
    
    static func requestPermissionForNotifications()
    {
        center.requestAuthorization(options: options)
        {
            (granted, error) in
            if !granted
            {
                print("Notification permissions error")
            }
        }
    }
    
    static func createEventNotification(for event: Event){
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.sound = UNNotificationSound.default()
        var body = "at \(event.startTime.description)"
        switch UserData.userCalendar.compare(Date(), to: event.date, toGranularity: .day) {
        case .orderedDescending:
            print("Error: Event in past")
        case .orderedSame:
            body = "Today \(body)"
        case .orderedAscending:
            body = "Tomorrow \(body)"
        }
        content.body = body
//        let triggerDate = UserData.userCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: event.date) //FIXME
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//        Testing
        var comp = DateComponents()
        comp.year = 2017
        comp.month = 6
        comp.day = 14
        comp.hour = 16
        comp.minute = 4
        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)

        let request = UNNotificationRequest(identifier: event.title, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let _ = error {
                //FIXME
                //Something went wrong
            }
        })
    }
    
    //For testing
    static func addNotificationsForAll(){
        UserData.allEvents.forEach({date,values in
            values.forEach({
                createEventNotification(for: $0)
            })
        })
        center.getPendingNotificationRequests(completionHandler: {
            print($0.forEach({
                print($0.content.title)
            }))
        })
    }
    
}
