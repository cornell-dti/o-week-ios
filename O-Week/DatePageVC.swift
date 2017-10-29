//
//  DatePageVC.swift
//  O-Week
//
//  Created by David Chu on 2017/10/24.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

/**
	Holds a reference to all `FeedVC`s, one for each day of orientation. Allows swiping between them.
	`pages`: All the `FeedVC`s
*/
class DatePageVC:UIPageViewController, UIPageViewControllerDataSource
{
	var datePicker:DatePickerController?
	var pages = [UIViewController]()
	
	/**
		Creates a `UIPageViewController` that transitions as expected (instead of transitioning through page flips).
	*/
	init()
	{
		super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
	}
	//must be written since we provided `init()`. Will not be used.
	required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder)}
	
	/**
		Sets up the `FeedVC`s, once for each day in orientation. Sets the first page to the one for the appropriate day.
	*/
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		//make sure this function only runs once
		guard pages.isEmpty else {
			return
		}
		
		UserData.DATES.forEach({pages.append(FeedVC(date: $0))})
		setViewControllers([pageForToday()], direction: .forward, animated: true, completion: nil)
		dataSource = self
		view.backgroundColor = UIColor.white
	}
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		setUpDatePicker()
	}
	private func setUpDatePicker()
	{
		//make sure this function only runs once
		guard datePicker == nil else {
			return
		}
		
		AppDelegate.setUpExtendedNavBar(navController: navigationController)
		
		datePicker = DatePickerController()
		addChildViewController(datePicker!)
		datePicker!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: Layout.DATE_SIZE)
		view.addSubview(datePicker!.view)
		datePicker!.didMove(toParentViewController: self)
	}
	/**
		Returns the `UIViewController` that comes before the one given, nil if the one given has no preceding page.
		- parameters:
			- pageViewController: Reference to self.
			- viewController: The view controller on display.
	*/
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
	{
		guard let index = pages.index(of: viewController) else {
			return nil
		}
		return index > 0 ? pages[index-1] : nil
	}
	/**
		Returns the `UIViewController` that comes after the one given, nil if the one given has no succeeding page.
		- parameters:
			- pageViewController: Reference to self.
			- viewController: The view controller on display.
	*/
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
	{
		guard let index = pages.index(of: viewController) else {
				return nil
		}
		return index < pages.count - 1 ? pages[index+1] : nil
	}
	/**
		Returns the `UIViewController` which contains a date corresponding to today's date. Returns the view controller at `page[0]` if there is no match.
		- Requires: `pages` is populated with UIViewControllers corresponding to `UserData.DATES`, in order.
		- Returns: UIViewController.
	*/
	private func pageForToday() -> UIViewController
	{
		let date = Date()
		let index = UserData.DATES.index(where: {UserData.userCalendar.compare($0, to: date, toGranularity: .day) == .orderedSame})
		return index == nil ? pages[0] : pages[index!]
	}
}
