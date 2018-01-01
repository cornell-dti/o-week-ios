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
        setStyles()
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
		Changes appearances of UI elements to match the theme.
	*/
    private func setStyles()
    {
        let navigationBarAppearence = UINavigationBar.appearance()
        
        navigationBarAppearence.barTintColor = Colors.BRIGHT_RED
        navigationBarAppearence.tintColor = UIColor.white   //back arrow is white
        navigationBarAppearence.isTranslucent = false
        navigationBarAppearence.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: Font.DEMIBOLD, size: 16)!]
		
		let switchAppearance = UISwitch.appearance()
		switchAppearance.onTintColor = Colors.RED
    }
	
	/**
		Starts the initial view controller with a navigation bar.
	*/
	private func startFirstVC()
	{
		if (UserData.isFirstRun())
		{
			window!.rootViewController = InitialSettingsVC.createWithNavBar()
		}
		else
		{
			window!.rootViewController = TabBarVC()
		}
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
}

