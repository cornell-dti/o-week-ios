//
//  UserData.swift
//  O-Week
//
//  Created by Vicente Caycedo on 4/28/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//
//  Holds a variety of user data

import Foundation
import CoreData
import UIKit

class UserData {
    
    // MARK:- Properties
    
    //Core Data
    static let eventEntityName = "EventEntity"
    static let addedPKsName = "AddedPKs" //KeyPath used for accessing added PKs in User Defaults
    
    //Settings
    static let allSettings: [(name: String, options: [String])] = [(name: "Receive reminders for...", options: ["No events", "All my events", "Only required events"]), (name: "Notify me...", options: ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"])]
    
    //Events
    static var allEvents: [Event] = []
    static var selectedEvents:Set<Event> = Set()
    
    //Calendar 
    static let userCalendar = Calendar.current
    
    //Dates 
    static var dates: [Date] = []
    
    private init(){}
    
    // MARK:- Core Data Helper Functions
    
    static func loadData(){
        /* Fetching PKs of added events */
        let defaults = UserDefaults.standard
        let added = defaults.stringArray(forKey: UserData.addedPKsName) ?? []
        
        /* Fetching Core Data */
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: UserData.eventEntityName, in: managedContext)!
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: UserData.eventEntityName)
        var data: [NSManagedObject] = []
        do {
            data = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if(data.isEmpty){
            //No data found on iPhone
            //TODO: Fix conditional statement, fetch data from DB and compare to Core Data to remove outdated events or add new events
            //Adding temp data for testing
            
            //let data = [Event(title:"A", caption:"A", start:Time(hour:9, minute:30), end:Time(hour:10, minute:30), description: nil), Event(title:"B", caption:"B", start:Time(hour:10, minute:30), end:Time(hour:12, minute:0), description: nil), Event(title:"C", caption:"C", start:Time(hour:11, minute:45), end:Time(hour:15, minute:30), description: nil), Event(title:"D", caption:"D", start:Time(hour:12, minute:0), end:Time(hour:14, minute:0), description: nil), Event(title:"E", caption:"E", start:Time(hour:13, minute:30), end:Time(hour:14, minute:0), description: nil), Event(title:"F", caption:"F", start:Time(hour:14, minute:0), end:Time(hour:15, minute:40), description: nil), Event(title:"G", caption:"G", start:Time(hour:14, minute:30), end:Time(hour:15, minute:0), description: nil), Event(title:"H", caption:"H", start:Time(hour:15, minute:30), end:Time(hour:16, minute:0), description: nil), Event(title:"I", caption:"I", start:Time(hour:16, minute:0), end:Time(hour:16, minute:30), description: nil), Event(title:"J", caption:"J", start:Time(hour:15, minute:50), end:Time(hour:16, minute:40), description: nil), Event(title:"K", caption:"K", start:Time(hour:17, minute:0), end:Time(hour:17, minute:30), description: nil)]
            //let events: [([String], [Int])] = [(["Alumni Families and Legacy Reception","Tent on Rawlings Green", "No description", "1"],[19, 7, 45, 8, 45]),(["New Student Convocation", "Shoellkopf Stadium", "This will be your official welcome from university administrators, as well as from your student body president and other key student leaders in Schoellkopf Stadium. Note that it takes 30 minutes to walk to Schoellkopf Stadium from North Campus and 20 minutes from West Campus; plan accordingly.", "2"], [20, 8, 45, 10, 0]),(["Tours of Libraries and Manuscript", "Upper Lobby, Uris Library", "No description", "3"], [21, 10, 0, 11, 30]),(["Dump and Run Sale", "Helen Newman Hall", "No description", "4"], [22, 10,0,18,0]),(["AAP—Dean’s Convocation", "Abby and Howard Milstein Hall", "No description", "5"], [23, 10, 30, 11, 30]),(["CALS—Dean’s Convocation", "Call Alumni Auditorium, Kennedy Hall", "No description", "6"], [19, 10, 30, 11, 30])]
            // Event Format: (["eventName", "caption", "description", "pk"], [date, starttimehr, starttimemin, endtimehr, endtimemin])
            let events: [([String], [Int])] = [(["Move In", "Multiple locations", "Students should plan to move into their residence halls between 9:00am and 12:00pm on Thursday, January 19. Orientation volunteers will help you move your belongings and answer any questions that you may have. Plan on picking up your key to your room at your service center before heading over to your residence hall. If you are living off campus, we also recommend moving in on Thursday so you can attend First Night at 8:00pm that evening.", "1"], [19, 9, 0, 12, 0]),(["New Student Check-In and Welcome Reception", "Willard Straight Hall, 4th Floor Rooms", "You are required to attend New Student Check-In in the Memorial Room to verify your matriculation and registration requirements. Please arrive anytime between 1:00pm and 2:30pm as representatives from across campus will also be available to answer questions and to better acquaint you with university services. Light refreshments will be available for students and parents throughout the fourth floor of Willard Straight Hall.", "2"], [19, 13, 0, 15, 0]), (["First Night", "Klarman Atrium, Klarman Hall", "It's your first night at Cornell! Meet your January Orientation Leader (JOL) and then mingle with your classmates and get a taste of what Ithaca has to offer - literally! There will be free food and drinks as well as games and activities. You won't want to miss it!", "3"], [19, 19, 0, 20, 0]), (["Cornell Essentials", "Kaufman Auditorium, G64 Goldwin Smith Hall", "Hear from upper-level students and alumni about their own introduction to Cornell. Learn how to navigate the university, deal with setbacks, find balance, and take advantage of the multitude of campus resources available. All new first-year and transfer students must attend this event. First year students will walk to the FYSA Class Photo event from Goldwin Smith Hall.", "4"], [20, 15, 0, 16, 0]), (["Welcome Dinner", "Becker House, Robert Purcell Marketplace Eatery", "Join us on West Campus in the Becker House Dining Room or on North Campus in the Robert Purcell Marketplace Eatery. If you don’t have a meal plan, don’t worry, we’ve got you covered at the door. Students living in the Collegetown area and West Campus are encouraged to go to Becker House. FYSAs and students living on North Campus are encouraged to go to RPCC.", "5"], [20, 6, 0, 7, 30]) , (["Coffee Hour", "Café Jennie, The Cornell Store", "Visit Café Jennie in The Cornell Store for free coffee and hot chocolate! Join in on casual conversation with both new and current students to discuss life at Cornell.", "6"], [21, 10, 0, 11, 0]) , (["Laser Tag", "2nd Floor, RPCC", "Calling all First Years! You've proven you can handle yourself in a classroom, but how will you fair in a blood pumping, heart racing laser fight? Join your fellow Cornellians at Barskis Xtreme Lazer Tag for an adrenaline-fueled test of agility, precision, and wit.", "7"], [21, 13, 0, 15, 0]), (["Study Smarter, Not Harder", "Lewis Auditorium, G76 Goldwin Smith Hall", "Are you ready to conquer procrastination and stress while maximizing your learning experience? Join the Learning Strategies Center's Mile Chen and learn how to make the most of your study skills. Get ahead of the game!", "8"], [22, 11, 0, 12, 0]), (["Explore Downtown Ithaca", "Risley or Schwartz Center Bus Stop", "Interested in learning about downtown Ithaca? Want to take advantage of your free bus pass? Come learn about the TCAT bus system and get acquainted with downtown Ithaca through a series of group activities on the Commons. Win free samples and prizes. We will meet at the bus stop in front of Risley Hall or Schwartz Center and take the bus down together, snow or shine.", "9"], [22, 1, 0, 15, 0]), (["Cuddles and Chocolate", "Memorial Room, WSH", "Play with puppies from Guiding Eyes for the Blind at Cornell during this afternoon of hot chocolate and cuddles! Guiding Eyes for the Blind at Cornell strives to teach students to learn more about guide dog training and provide support for the Guiding Eyes for the Blind Finger Lakes Region.", "10"], [23, 13, 0, 14, 0]), (["Learning Where You Live", "3331 Tatkon Center", "Want to take a small class where you get to know the professor and the other students? Curious to learn about a subject that has nothing to do with your intended major? Want to explore a really interesting subject without the pressure of grades? Come check out a few of the one-credit courses being taught on North Campus this year.", "11"], [23, 16, 0, 17, 0]), (["Orientation Finale at the Tatkon Center", "Tatkon Center", "Join us for a celebration! Orientation may be coming to a close, but your first semester at Cornell is just getting started. Mingle with friends, meet current students, and get excited for a great semester. Don’t miss the refreshments and giveaways. JOLs will also introduce you to the Tatkon Center, Cornell’s academic resource center for first-year students.", "12"], [24, 11, 0, 13, 0])]
            var dateComponents = DateComponents()
            dateComponents.year = 2017
            dateComponents.month = 08
            for event in events {
                let evnt = NSManagedObject(entity: entity, insertInto: managedContext)
                evnt.setValue(event.0[0], forKeyPath: "title")
                evnt.setValue(event.0[1], forKeyPath: "caption")
                evnt.setValue(event.0[2], forKeyPath: "eventDescription")
                evnt.setValue(event.0[3], forKeyPath: "pk")
                evnt.setValue(event.1[1], forKeyPath: "startTimeHr")
                evnt.setValue(event.1[2], forKeyPath: "startTimeMin")
                evnt.setValue(event.1[3], forKeyPath: "endTimeHr")
                evnt.setValue(event.1[4], forKeyPath: "endTimeMin")
                evnt.setValue(false, forKeyPath: "required")
                dateComponents.day = event.1[0]
                let date = UserData.userCalendar.date(from: dateComponents)
                evnt.setValue(date, forKeyPath: "date")
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            do {
                data = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        for obj in data {
            let event = Event(obj)
            if(!UserData.allEvents.contains(event)){
                UserData.allEvents.append(event)
                if(!UserData.selectedEvents.contains(event) && added.contains(event.pk)){
                    UserData.selectedEvents.insert(event)
                }
            }
            if(!UserData.dates.contains(event.date)){
                UserData.dates.append(event.date)
            }
        }
        UserData.dates.sort()
        //Telling other classes to reload their data
        NotificationCenter.default.post(name: .reload, object: nil)
    }
    
    static func savePKs(){
        let defaults = UserDefaults.standard
        var addedPks: [String] = []
        for evnt in UserData.selectedEvents {
            addedPks.append(evnt.pk)
        }
        defaults.setValue(addedPks, forKey: UserData.addedPKsName)
    }
}
