//
//  LocalNotifications.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/13/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotifications: NSObject, UNUserNotificationCenterDelegate {
    
    static let center = UNUserNotificationCenter.current()
    static let options: UNAuthorizationOptions = [.alert, .sound, .badge]

    static func requestPermissionForNotifications()
    {
        center.requestAuthorization(options: options)
        {
            (granted, error) in
            if !granted
            {
                //FIXME
                print("Notification permissions error")
            }
        }
    }
    
    static func addNotification(for event: Event){
        if let chosenOption = UserPreferences.setForSetting.chosen {
            switch chosenOption {
            case UserPreferences.setForSetting.options[0]: //"All my events"
                createEventNotification(for: event)
            case UserPreferences.setForSetting.options[1]: //"Only required events"
                if(event.required){
                    createEventNotification(for: event)
                }
            default:
                print("Unrecognized setForSetting")
                break
            }
        }
    }
    
    static func removeNotification(for event: Event){
        center.removePendingNotificationRequests(withIdentifiers: [event.title])
    }
    
    static private func createEventNotification(for event: Event){
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
        
        let interval = UserPreferences.timeIntervalsForNotification[UserPreferences.notifyMeSetting.name] ?? getIntervalFor7AM(for: event.date)
        let dateForNotification = event.date.addingTimeInterval(interval)
        let triggerDate = UserData.userCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: dateForNotification)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.title, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let _ = error {
                //FIXME , Something went wrong
            }
        })
    }
    
    static private func getIntervalFor7AM(for date: Date) -> TimeInterval {
        let comp = Calendar.current.dateComponents([.year, .month, .day], from: date)
        var newDate = Calendar.current.date(from: comp)
        newDate?.addTimeInterval(25200)
        return newDate!.timeIntervalSince(date) //Returns negative number for events after 7 AM for consistency with UserPreferences.timeIntervalsForNotification
    }
    
    static func updateNotifications(){
        center.removeAllPendingNotificationRequests()
        UserData.selectedEvents.forEach({ (date, events) in
            events.forEach({
                addNotification(for: $0)
            })
        })
    }
    
    //Allows local notifications to show while app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }
    
}
