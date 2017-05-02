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
    //TODO: fetch from core data
    //static var allSettings: [Setting] = []
    static var allSettings = [Setting(name: "Reminders Set For", allOptions: ["No events", "All my events", "Only required events"], chosenOption: "No events"), Setting(name: "Notify Me", allOptions: ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"], chosenOption: "At time of event")]
    
    //Events
    static var allEvents: [Event] = []
    static var selectedEvents:Set<Event> = Set()
    
    
}
