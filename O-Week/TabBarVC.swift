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
		schedulePageVC.tabBarItem = UITabBarItem(title: "Calendar", image: nil, tag: 0)
		let feedPageVC = DatePageVC.createWithNavBar(with: .feed)
		feedPageVC.tabBarItem = UITabBarItem(title: "Browse", image: nil, tag: 1)
		viewControllers = [schedulePageVC, feedPageVC]
	}
}
