//
//  AppDelegate.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/13/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

/**
	First class that is accessed when app first launches. Responsible for setting up stylistic themes, notifications, and handling app life cycle events.
*/
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?
	var delegate:LocalNotifications!
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
	{
		window = UIWindow(frame: UIScreen.main.bounds)
        setNavBarColor()
        LocalNotifications.requestPermissionForNotifications()
        setDelegateForNotifications()
        UserData.loadData()
		startFirstVC()
		
        return true
    }
	
	/**
		Sets the navigation bar so that it merges seamlessly with the `DatePickerController` directly below it. Should be called by ViewControllers that use date pickers.
		- parameter navController: A reference to the ViewController's navigation bar controller.
	*/
    static func setUpExtendedNavBar(navController: UINavigationController?)
	{
        navController?.navigationBar.shadowImage = UIImage(named: "transparent_pixel")
        navController?.navigationBar.setBackgroundImage(UIImage(named: "pixel"), for: .default)
    }
	
	/**
		Changes the navigation bar's style to our theme color, and changes the text so that it's AvenirNext.
	*/
    private func setNavBarColor()
    {
        let navigationBarAppearence = UINavigationBar.appearance()
        
        navigationBarAppearence.barTintColor = Colors.RED
        navigationBarAppearence.tintColor = UIColor.white   //back arrow is black
        navigationBarAppearence.isTranslucent = false
        navigationBarAppearence.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 14)!]
    }
	
	/**
		Starts the initial view controller.
	*/
	private func startFirstVC()
	{
		let datePageVC = DatePageVC()
		let navController = UINavigationController(rootViewController: datePageVC)
		navController.navigationBar.topItem?.title = "Orientation Events"
		AppDelegate.setUpExtendedNavBar(navController: navController)
		window!.rootViewController = navController
		window!.makeKeyAndVisible()
	}
	
    private func setDelegateForNotifications()
	{
        let center = UNUserNotificationCenter.current()
		delegate = LocalNotifications(window:window!)
        center.delegate = delegate
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UserData.saveAddedPKs()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        UserData.loadData()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        UserData.saveAddedPKs()
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
}

