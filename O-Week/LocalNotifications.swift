//
//  LocalNotifications.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/13/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import Foundation
import UserNotifications

/**
	Manages local notifications.
	`center`: Reference to notification center.
	`options`: The ways in which notifications will be presented to the user.
*/
class LocalNotifications: NSObject, UNUserNotificationCenterDelegate
{
    
    static let center = UNUserNotificationCenter.current()
    static let options: UNAuthorizationOptions = [.alert, .sound, .badge]

	/**
		Ask user for permission to send notifications.
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
	/**
		Send a notification for orientation events that were updated.
		- paramter updatedEvents: Names of events that were updated. These event names will be displayed in the notification.
	*/
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
	
	/**
		Removes notifications for the given event.
		- parameter event: Event to remove notifications for.
	*/
    static func removeNotification(for event: Event)
	{
        center.removePendingNotificationRequests(withIdentifiers: [event.title])
    }
	
	/**
		Creates a notification for the given event, setting up its time according to saved preferences.
		- parameter event: Event to create notifications for.
	*/
    static func createEventNotification(for event: Event)
	{
		let notifyMeTime = ListPreference.NotifyTime.get()
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.sound = UNNotificationSound.default()
        content.body = notifyMeTime == .OneDayBefore ? "Tomorrow at \(event.startTime.description)" : "Today at \(event.startTime.description)"

        let interval = notifyMeTime.timeInterval() ?? getIntervalFor7AM(from: event.startTime)
        var componentsForTrigger = UserData.userCalendar.dateComponents([.year,.month,.day], from: event.date)
        componentsForTrigger.hour = event.startTime.hour
        componentsForTrigger.minute = event.startTime.minute
        let triggerDate = UserData.userCalendar.date(from: componentsForTrigger)?.addingTimeInterval(interval)
        let updatedComponents = UserData.userCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: triggerDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: updatedComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.title, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
	
	/**
		Returns the amount of time between the given `Time` and 7AM of that day.
		- parameter time: Time of event.
		- returns: Time from 7AM to given time.
	*/
    private static func getIntervalFor7AM(from time: Time) -> TimeInterval
	{
        return TimeInterval(25200 - (time.toMinutes() * 60)) //Returns negative number for events after 7 AM for consistency with UserPreferences.timeIntervalsForNotification
    }
	
	/**
		Removes and re-adds all notifications.
	*/
    static func updateNotifications()
	{
        center.removeAllPendingNotificationRequests()
		
		//only resend notifications if the user wants us to
		guard BoolPreference.Reminder.get() else {
			return
		}
        UserData.selectedEvents.forEach({ (date, events) in
            events.forEach({
                createEventNotification(for: $0)
            })
        })
    }
	
	/**
		Catches local notifications while app is open and displays them.
		- parameters:
			- center: Same as global variable.
			- notification: The notification that will be shown.
			- completionHandler: Function to run asynchronously (I think).
	*/
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
	{
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }
    
}
