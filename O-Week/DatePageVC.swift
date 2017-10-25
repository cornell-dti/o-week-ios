//
//  DatePageVC.swift
//  O-Week
//
//  Created by David Chu on 2017/10/24.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

class DatePageVC:UIPageViewController, UIPageViewControllerDataSource
{
	var pages = [UIViewController]()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		for date in UserData.DATES
		{
			let feedVC = FeedVC()
			feedVC.date = date
			pages.append(feedVC)
		}
		
		setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
		dataSource = self
	}
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
	{
		guard let index = pages.index(of: viewController) else {
			return nil
		}
		return index > 0 ? pages[index-1] : nil
	}
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
	{
		guard let index = pages.index(of: viewController) else {
				return nil
		}
		return index < pages.count - 1 ? pages[index+1] : nil
	}
}
