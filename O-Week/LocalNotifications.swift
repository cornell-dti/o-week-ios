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
                print("Notification permissions error")
            }
        }
    }
	
	static func addNotification(for updatedEvents:[String])
	{
		guard !updatedEvents.isEmpty else {
			return
		}
		
		print("setting up notification")
		let content = UNMutableNotificationContent()
		content.title = "Orientation events have been updated"
		content.body = "The following events were changed: " + updatedEvents.joined(separator: ", ")
		let request = UNNotificationRequest(identifier: content.title, content: content, trigger: nil)
		center.add(request, withCompletionHandler: nil)
	}
    
    static func addNotification(for event: Event)
	{
        if let chosenOption = UserPreferences.setForSetting.chosen, UserPreferences.notifyMeSetting.chosen != nil
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
        content.body = UserPreferences.notifyMeSetting.chosen == "1 day before" ? "Tomorrow at \(event.startTime.description)" : "Today at \(event.startTime.description)"

        let interval = UserPreferences.timeIntervalsForNotification[UserPreferences.notifyMeSetting.chosen!] ?? getIntervalFor7AM(from: event.startTime)
        var componentsForTrigger = UserData.userCalendar.dateComponents([.year,.month,.day], from: event.date)
        componentsForTrigger.hour = event.startTime.hour
        componentsForTrigger.minute = event.startTime.minute
        let triggerDate = UserData.userCalendar.date(from: componentsForTrigger)?.addingTimeInterval(interval)
        let updatedComponents = UserData.userCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: triggerDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: updatedComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.title, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
    
    static private func getIntervalFor7AM(from time: Time) -> TimeInterval
	{
        return TimeInterval(25200 - (time.toMinutes() * 60)) //Returns negative number for events after 7 AM for consistency with UserPreferences.timeIntervalsForNotification
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
