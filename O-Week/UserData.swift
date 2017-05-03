//
//  UserData.swift
//  O-Week
//
//  Created by Vicente Caycedo on 4/28/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//
//  Holds user's added events

import Foundation
import CoreData

class UserData {
    
    //Settings
    static let allSettings: [(name: String, options: [String])] = [(name: "Reminders Set For", options: ["No events", "All my events", "Only required events"]), (name: "Notify Me", options: ["No notifications", "At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"])]
    
    //Events
    static var allEvents: [Event] = []
    static var selectedEvents:Set<Event> = Set()
    
    //Calendar 
    static let userCalendar = Calendar.current
    
}
