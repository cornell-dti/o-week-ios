//
//  LocalNotifications.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/13/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit
import UserNotifications

/**
	Manages local notifications.
	`EVENT_UPDATED_ID`: An event updated notification is to have the identifier with this as prefix to the pk value.
	`center`: Reference to notification center.
	`options`: The ways in which notifications will be presented to the user.
*/
class LocalNotifications: NSObject, UNUserNotificationCenterDelegate
{
	static let EVENT_UPDATED_ID = "change"
    static let center = UNUserNotificationCenter.current()
    static let options: UNAuthorizationOptions = [.alert, .sound, .badge]
	let window:UIWindow

	init(window:UIWindow)
	{
		self.window = window
	}
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
	static func addNotification(for updatedEvents:[Event])
	{
		guard !updatedEvents.isEmpty else {
			return
		}
		
		updatedEvents.forEach({
			let content = UNMutableNotificationContent()
			content.title = "\"\($0.title)\" has been updated"
			let request = UNNotificationRequest(identifier: "change\($0.pk)", content: content, trigger: nil)
			center.add(request, withCompletionHandler: nil)
		})
	}
	
	/**
		Removes notifications for the given event.
		- parameter eventPk: Pk of event to remove notifications for.
	*/
    static func removeNotification(for eventPk: Int)
	{
        center.removePendingNotificationRequests(withIdentifiers: [String(eventPk)])
    }
	
	/**
		Creates a notification for the given event, setting up its time according to saved preferences. Assumes that user has reminders turned on.
		- parameter event: Event to create notifications for.
	*/
    static func createNotification(for event: Event)
	{
		let notifyMeTime = ListPreference.NotifyTime.get()
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.sound = UNNotificationSound.default()
        content.body = notifyMeTime == .OneDayBefore ? "Tomorrow at \(event.startTime.description)" : "Today at \(event.startTime.description)"

        var componentsForTrigger = UserData.userCalendar.dateComponents([.year,.month,.day], from: event.date)
		
		//go to the next day if this event starts after midnight
		if (event.startTime.hour <= ScheduleVC.END_HOUR)
		{
			componentsForTrigger.day! += 1
		}
		
        componentsForTrigger.hour = event.startTime.hour
        componentsForTrigger.minute = event.startTime.minute
		
		let interval = notifyMeTime.timeInterval()!
        let triggerDate = UserData.userCalendar.date(from: componentsForTrigger)?.addingTimeInterval(interval)
        let updatedComponents = UserData.userCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: triggerDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: updatedComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: String(event.pk), content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
	
	/**
		Removes and re-adds all notifications.
	*/
    static func updateNotifications()
	{
        center.removeAllPendingNotificationRequests()
		
		//only resend notifications if the user wants us to
		guard BoolPreference.Reminder.isTrue() else {
			return
		}
        UserData.selectedEvents.forEach({ (date, events) in
            events.forEach({createNotification(for: $0)})
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
		//TODO don't do this for category updates
        completionHandler([.alert,.sound])
    }
	/**
		Responds when the user clicks on a nofitication action. Should open `DetailsVC` if the user presses an updated event notification.
		- parameters:
			- center: Same as global variable.
			- response: Contains info about the action & notification the user selected.
			- completionHandler: Function to run asynchronously (I think)
	*/
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
	{
		//check if updated event is actionable
		let id = response.notification.request.identifier
		if (id.contains(LocalNotifications.EVENT_UPDATED_ID))
		{
			let pk = Int(id.components(separatedBy: LocalNotifications.EVENT_UPDATED_ID)[1])
			if let event = UserData.eventFor(pk!)
			{
				let detailsVC = DetailsVC()
				detailsVC.configure(event: event)
				let navigationController = window.rootViewController?.navigationController
				navigationController?.pushViewController(detailsVC, animated: true)
			}
		}
	}
}
