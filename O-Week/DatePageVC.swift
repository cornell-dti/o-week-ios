//
//  DatePageVC.swift
//  O-Week
//
//  Created by David Chu on 2017/10/24.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

/**
	Holds a reference to all `FeedVC`s and `ScheduleVC`s, one for each day of orientation. Allows swiping between them.
	`pages`: All the `FeedVC`s or `ScheduleVC`s. Whatever these are, they must implement the `DateContainer` protocol in order to change `UserData.selectedDate` on page change.
`style`: Whether the page displayed is a `FeedVC` or a `ScheduleVC`.
`detailsVC`: A reference to the details page for the `FeedVC` or `ScheduleVC` to use. Stored here for reuse between different pages.
`filterVC`: A reference to the filter selection page for `FeedVC`. Stored here since `FeedVC` shouldn't control the navigation bar, where the filter button resides.
*/
class DatePageVC:UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
	var datePicker:DatePickerController?
	var pages = [UIViewController]()
	var style:Style!
	var detailsVC:DetailsVC!
	var filterVC:FilterVC?
	
	/**
		Creates a `DatePageVC` with a navigation bar that holds either `FeedVC`s or `ScheduleVC`s based on the style given.
		- parameter style: ViewController type.
		- returns: NavigationController container `DatePageVC`.
	*/
	static func createWithNavBar(with style:Style) -> UINavigationController
	{
		let datePageVC = DatePageVC(with: style)
		let navController = UINavigationController(rootViewController: datePageVC)
		switch style
		{
		case .feed:
			navController.navigationBar.topItem?.title = "Browse Events"
			navController.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter")!, style: .plain, target: datePageVC, action: #selector(onFilterClick))
			datePageVC.filterVC = FilterVC()
		case .schedule:
			navController.navigationBar.topItem?.title = "My Schedule"
		}
		AppDelegate.setUpExtendedNavBar(navController: navController)
		datePageVC.detailsVC = DetailsVC()
		return navController
	}
	
	/**
		Creates a `UIPageViewController` that transitions as expected (instead of transitioning through page flips).
	*/
	convenience init(with style:Style)
	{
		self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
		self.style = style
	}
	
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
		
		if (style == .feed)
		{
			UserData.DATES.forEach({pages.append(FeedVC(date: $0, detailsVC: detailsVC))})
		}
		else if (style == .schedule)
		{
			UserData.DATES.forEach({pages.append(ScheduleVC(date: $0, detailsVC: detailsVC))})
		}
		
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
		
		datePicker = DatePickerController()
		addChildViewController(datePicker!)
		datePicker!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: Layout.DATE_SIZE)
		view.addSubview(datePicker!.view)
		datePicker!.didMove(toParentViewController: self)
	}
	/**
		Synchronize the page with `UserData.selectedDate`, which could've been changed by other classes.
	*/
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
	
	/**
		Creates space at the top of the table where the `DatePickerController` will be displayed. Will be called by `FeedVC` and `ScheduleVC`.
	*/
	static func makeSpaceForDatePicker(in scrollable:UIScrollView)
	{
		let topMargin = UIEdgeInsets(top: Layout.DATE_SIZE, left: 0, bottom: 0, right: 0)
		scrollable.contentInset = topMargin
		scrollable.scrollIndicatorInsets = topMargin
		//scroll to top
		scrollable.setContentOffset(CGPoint(x: 0, y: -Layout.DATE_SIZE), animated: false)
	}
	
	/**
		Open the filter when it is clicked.
	*/
	@objc func onFilterClick()
	{
		guard filterVC != nil else {
			print("DatePageVC: filter clicked, but filterVC is nil")
			return
		}
		navigationController?.pushViewController(filterVC!, animated: true)
	}
	
	/**
		Determines whether `DatePageVC` will display events as a feed or a user's personalized schedule.
	*/
	enum Style
	{
		case feed, schedule
	}
}
