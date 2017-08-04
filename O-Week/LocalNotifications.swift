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
                // FIXME: Ask user to give permission
                print("Notification permissions error")
            }
        }
    }
    
    static func addNotification(for event: Event)
	{
        if let chosenOption = UserPreferences.setForSetting.chosen
		{
            switch chosenOption
			{
            case UserPreferences.setForSetting.options[0]: //"All my events"
                createEventNotification(for: event)
            case UserPreferences.setForSetting.options[1]: //"Only required events"
                if(event.required)
				{
                    createEventNotification(for: event)
                }
            default:
                print("Unrecognized setForSetting")
            }
        }
    }
    
    static func removeNotification(for event: Event)
	{
        center.removePendingNotificationRequests(withIdentifiers: [event.title])
    }
    
    static private func createEventNotification(for event: Event)
	{
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.sound = UNNotificationSound.default()
        var body = "at \(event.startTime.description)"
		
        guard UserPreferences.notifyMeSetting.chosen != nil else {
            // FIXME: check functionality
            return
        }
        let interval = UserPreferences.timeIntervalsForNotification[UserPreferences.notifyMeSetting.chosen!] ?? getIntervalFor7AM(for: event.date)
        
        if let preference = UserPreferences.notifyMeSetting.chosen, preference != "1 day before" {
            body = "Today \(body)"
        } else {
            body = "Tomorrow \(body)"
        }
        content.body = body
        
        // TODO: clean up code
        var componentsForTrigger = UserData.userCalendar.dateComponents([.year,.month,.day], from: event.date)
        componentsForTrigger.hour = event.startTime.hour
        componentsForTrigger.minute = event.startTime.minute
        let triggerDate = UserData.userCalendar.date(from: componentsForTrigger)?.addingTimeInterval(interval)
        let updatedComponents = UserData.userCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: triggerDate!)
        //let dateForNotification = event.date.addingTimeInterval(interval)
        //let triggerDate = UserData.userCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: dateForNotification)
        let trigger = UNCalendarNotificationTrigger(dateMatching: updatedComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.title, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let _ = error {
                //FIXME: Something went wrong
            }
        })
    }
    
    static private func getIntervalFor7AM(for date: Date) -> TimeInterval
	{
        let comp = Calendar.current.dateComponents([.year, .month, .day], from: date)
        var newDate = Calendar.current.date(from: comp)
        newDate?.addTimeInterval(25200)
        return newDate!.timeIntervalSince(date) //Returns negative number for events after 7 AM for consistency with UserPreferences.timeIntervalsForNotification
    }
    
    static func updateNotifications()
	{
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
