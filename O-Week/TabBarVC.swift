//
//  TabBarVC.swift
//  O-Week
//
//  Created by David Chu on 2017/10/29.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

class TabBarVC:UITabBarController
{
	/**
		Set the tab bar item views.
	*/
	override func viewDidLoad()
	{
		let schedulePageVC = DatePageVC.createWithNavBar(with: .schedule)
		schedulePageVC.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(named: "tab_calendar"), tag: 0)
		let feedPageVC = DatePageVC.createWithNavBar(with: .feed)
		feedPageVC.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(named: "tab_browse"), tag: 1)
		let searchVC = SearchVC.createWithNavBar()
		searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "tab_search"), tag: 2)
		let settingsVC = SettingsVC.createWithNavBar()
		settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "tab_settings"), tag: 3)
		
		viewControllers = [schedulePageVC, feedPageVC, searchVC, settingsVC]
		tabBar.tintColor = Colors.BRIGHT_RED
	}
}
