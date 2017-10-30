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
	`pages`: All the `FeedVC`s or `ScheduleVC`s. Whatever these are, they must implement the `DateContainer` protocol in order to change `UserData.selectedDate` on page change.
*/
class DatePageVC:UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
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
		let pageToShow = pages[UserData.DATES.index(of: UserData.selectedDate)!]
		setViewControllers([pageToShow], direction: .forward, animated: true, completion: nil)
		dataSource = self
		delegate = self
		view.backgroundColor = UIColor.white
		NotificationCenter.default.addObserver(self, selector: #selector(syncSelectedDate), name: .dateChanged, object: nil)
	}
	/**
		Create the date picker.
	*/
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		//make sure this function only runs once
		guard datePicker == nil else {
			return
		}
		
		//get rid of shadow under nav bar
		AppDelegate.setUpExtendedNavBar(navController: navigationController)
		
		datePicker = DatePickerController()
		addChildViewController(datePicker!)
		datePicker!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: Layout.DATE_SIZE)
		view.addSubview(datePicker!.view)
		datePicker!.didMove(toParentViewController: self)
	}
	@objc func syncSelectedDate()
	{
		guard let currentVC = viewControllers?[0] as? DateContainer else {
			return
		}
		guard UserData.selectedDate != currentVC.date else {
			return
		}
		
		let newPage = pages[UserData.DATES.index(of: UserData.selectedDate)!]
		let direction:UIPageViewControllerNavigationDirection = (UserData.userCalendar.compare(currentVC.date, to: UserData.selectedDate, toGranularity: .day) == .orderedAscending) ? .forward : .reverse
		setViewControllers([newPage], direction: direction, animated: true, completion: nil)
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
		If the user swipes to a new page, notify other classes about the change.
		- parameters:
			- pageViewController: Reference to self.
			- finished: Whether the animation has finished.
			- previousViewControllers: The viewController the user swiped FROM.
			- completed: Whether the user swiped to a new page (or stayed on the same).
	*/
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
	{
		guard completed else {
			return
		}
		
		let currentVC = viewControllers![0] as! DateContainer
		UserData.selectedDate = currentVC.date
		NotificationCenter.default.post(name: .dateChanged, object: nil)
	}
}
