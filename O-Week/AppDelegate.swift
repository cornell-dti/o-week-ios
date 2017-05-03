//
//  AppDelegate.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/13/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static let eventEntityName = "EventEntity"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setNavBarColor()
        checkForSettingsAndSet()
        loadData()
        return true
    }
    
    private func setNavBarColor()
    {
        let navigationBarAppearence = UINavigationBar.appearance()
        
        navigationBarAppearence.barTintColor = Color.RED
        navigationBarAppearence.tintColor = UIColor.white   //back arrow is black
        navigationBarAppearence.isTranslucent = false
        navigationBarAppearence.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 14)!]
    }
    
    private func checkForSettingsAndSet(){
        let defaults = UserDefaults.standard
        if(defaults.string(forKey: "Reminders Set For") == nil){
            defaults.set("No events", forKey: "Reminders Set For")
        }
        if(defaults.string(forKey: "Notify Me") == nil){
            defaults.set("No notifications", forKey: "Notify Me")
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveData()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        loadData()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "O-Week")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK:- Core Data Helper Functions
    
    func loadData(){
        /* Fetching Core Data */
        let managedContext = self.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: AppDelegate.eventEntityName, in: managedContext)!
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: AppDelegate.eventEntityName)
        var tempArray: [NSManagedObject] = []
        do {
            tempArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        tempArray.reverse() //Elements are retrieved FILO
        
        if(tempArray.isEmpty){
            //No data found on iPhone
            //TODO: Fix conditional statement, fetch data from DB and compare to Core Data to remove outdated events or add new events
            //Adding temp data for testing
            
            //let data = [Event(title:"A", caption:"A", start:Time(hour:9, minute:30), end:Time(hour:10, minute:30), description: nil), Event(title:"B", caption:"B", start:Time(hour:10, minute:30), end:Time(hour:12, minute:0), description: nil), Event(title:"C", caption:"C", start:Time(hour:11, minute:45), end:Time(hour:15, minute:30), description: nil), Event(title:"D", caption:"D", start:Time(hour:12, minute:0), end:Time(hour:14, minute:0), description: nil), Event(title:"E", caption:"E", start:Time(hour:13, minute:30), end:Time(hour:14, minute:0), description: nil), Event(title:"F", caption:"F", start:Time(hour:14, minute:0), end:Time(hour:15, minute:40), description: nil), Event(title:"G", caption:"G", start:Time(hour:14, minute:30), end:Time(hour:15, minute:0), description: nil), Event(title:"H", caption:"H", start:Time(hour:15, minute:30), end:Time(hour:16, minute:0), description: nil), Event(title:"I", caption:"I", start:Time(hour:16, minute:0), end:Time(hour:16, minute:30), description: nil), Event(title:"J", caption:"J", start:Time(hour:15, minute:50), end:Time(hour:16, minute:40), description: nil), Event(title:"K", caption:"K", start:Time(hour:17, minute:0), end:Time(hour:17, minute:30), description: nil)]
            let events: [([String], [Int])] = [(["Alumni Families and Legacy Reception","Tent on Rawlings Green", "No description"],[7, 45, 8, 45]), (["New Student Convocation", "Shoellkopf Stadium", "This will be your official welcome from university administrators, as well as from your student body president and other key student leaders in Schoellkopf Stadium. Note that it takes 30 minutes to walk to Schoellkopf Stadium from North Campus and 20 minutes from West Campus; plan accordingly."], [8, 45, 10, 0]), (["Tours of Libraries and Manuscript", "Upper Lobby, Uris Library", "No description"], [10, 0, 11, 30]), (["Dump and Run Sale", "Helen Newman Hall", "No description"], [10,0,18,0]), (["AAP—Dean’s Convocation", "Abby and Howard Milstein Hall", "No description"], [10, 30, 11, 30]), (["CALS—Dean’s Convocation", "Call Alumni Auditorium, Kennedy Hall", "No description"], [10, 30, 11, 30])]
            for event in events {
                let evnt = NSManagedObject(entity: entity, insertInto: managedContext)
                evnt.setValue(event.0[0], forKeyPath: "title")
                evnt.setValue(event.0[1], forKeyPath: "caption")
                evnt.setValue(event.0[2], forKeyPath: "eventDescription")
                evnt.setValue(false, forKey: "added")
                evnt.setValue(event.1[0], forKeyPath: "startTimeHr")
                evnt.setValue(event.1[1], forKeyPath: "startTimeMin")
                evnt.setValue(event.1[2], forKeyPath: "endTimeHr")
                evnt.setValue(event.1[3], forKeyPath: "endTimeMin")
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            do {
                tempArray = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            tempArray.reverse() //Elements are retrieved FILO
        }
        for obj in tempArray {
            let title = obj.value(forKeyPath: "title") as? String
            let cap = obj.value(forKeyPath: "caption") as? String
            let descrip = obj.value(forKeyPath: "eventDescription") as? String
            let start = Time(hour: (obj.value(forKeyPath: "startTimeHr") as? Int)!, minute: (obj.value(forKeyPath: "startTimeMin") as? Int)!)
            let end = Time(hour: (obj.value(forKeyPath: "endTimeHr") as? Int)!, minute: (obj.value(forKeyPath: "endTimeMin") as? Int)!)
            let added = obj.value(forKeyPath: "added") as? Bool
            let event = Event(title: title!, caption: cap!, start: start, end: end, description: descrip, added: added)
            UserData.allEvents.append(event)
            if(added!){
                UserData.selectedEvents.insert(event)
            }
        }
        //Telling other classes to reload their data
        NotificationCenter.default.post(name: .reload, object: nil)
    }
    
    func saveData(){
        // TODO: Optimize by simply changing attribute, not deleting and storing again
        /* Deleting all stored data */
        let managedContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: AppDelegate.eventEntityName)
        let entity = NSEntityDescription.entity(forEntityName: AppDelegate.eventEntityName, in: managedContext)!
        var tempArray: [NSManagedObject] = []
        do {
            tempArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for item in tempArray {
            managedContext.delete(item)
        }
        /* Storing new data with updated added values*/
        for event in UserData.allEvents{
            let eventToStore = NSManagedObject(entity: entity, insertInto: managedContext)
            eventToStore.setValue(event.title, forKeyPath: "title")
            eventToStore.setValue(event.caption, forKeyPath: "caption")
            eventToStore.setValue(event.description, forKeyPath: "eventDescription")
            eventToStore.setValue(event.added, forKey: "added")
            eventToStore.setValue(event.startTime.hour, forKeyPath: "startTimeHr")
            eventToStore.setValue(event.startTime.minute, forKeyPath: "startTimeMin")
            eventToStore.setValue(event.endTime.hour, forKeyPath: "endTimeHr")
            eventToStore.setValue(event.endTime.minute, forKeyPath: "endTimeMin")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        UserData.allEvents.removeAll()
        UserData.selectedEvents.removeAll()
    }
}
extension Notification.Name {
    static let reload = Notification.Name("reload")
    static let reloadSettings = Notification.Name("reloadSettings")
}

