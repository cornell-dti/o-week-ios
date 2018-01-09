//
//  InitialSettingsVC.swift
//  O-Week
//
//  Created by David Chu on 2017/12/2.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

/**
	Displays the tutorial that opens on the app's initial launch.
	`buttons`: The buttons and each page, and the info that each one is associated with. Required: `buttons.count` <= `pages.count`.
`waitingOnEventDownload`: True if the user is ready to end the tutorial but the events have yet to be downloaded.
*/
class InitialSettingsVC:UIPageViewController, UIPageViewControllerDataSource
{
	var pages:[UIViewController]!
	var buttons:[[(button:UILabel, pk:Int?)]] = []
	var waitingOnEventDownload = false
	var studentTypePk:Int? = nil
	var collegePk:Int? = nil
	
	/**
		Creates a `InitialSettingsVC` with a navigation bar.
		- returns: NavigationController containing `InitialSettingsVC`.
	*/
	static func createWithNavBar() -> UINavigationController
	{
		let initialSettingsVC = InitialSettingsVC()
		let navController = UINavigationController(rootViewController: initialSettingsVC)
		navController.navigationBar.topItem?.title = "O-Week"
		return navController
	}
	
	/**
		Set up the pages' style.
	*/
	convenience init()
	{
		self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
		NotificationCenter.default.addObserver(self, selector: #selector(onEventsReload), name: .reloadData, object: nil)
	}
	
	/**
		Create the pages.
	*/
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		guard pages == nil else {
			return
		}
		
		pages = [createPage1(), createPage2(), createPage3()]
		setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
		
		dataSource = self
	}
	/**
		Creates the text & buttons for page 1, with listeners for on click events.
		Adds buttons to `buttons` as the 0th element.
		- returns: the 1st page.
	*/
	private func createPage1() -> UIViewController
	{
		let page1 = PageVC()
		
		let container = createContainer(in: page1)
		let text = createTitle("What type of incoming student are you?", in: container)
		
		let freshmanButton = createButton(with: "Incoming Freshman", textSize: 24)
		container.addSubview(freshmanButton)
		freshmanButton.autoPinEdge(.top, to: .bottom, of: text, withOffset: 40)
		freshmanButton.autoPinEdge(toSuperviewEdge: .left)
		freshmanButton.autoPinEdge(toSuperviewEdge: .right)
		
		let transferButton = createButton(with: Student.Transfer.rawValue, textSize: 24)
		container.addSubview(transferButton)
		transferButton.autoPinEdge(.top, to: .bottom, of: freshmanButton, withOffset: Layout.MARGIN)
		transferButton.autoPinEdge(toSuperviewEdge: .left)
		transferButton.autoPinEdge(toSuperviewEdge: .right)
		transferButton.autoPinEdge(toSuperviewEdge: .bottom)
		
		buttons.append([(button:freshmanButton, pk:nil), (button:transferButton, pk:Student.Transfer.pk)])
		
		return page1
	}
	/**
		Creates the text & buttons for page 2, with listeners for on click events.
		Adds buttons to `buttons` as the 1st element.
	
		Required: `createPage1()` has been run (once).
		- returns: the 2nd page.
	*/
	private func createPage2() -> UIViewController
	{
		let page2 = PageVC()
		
		let container = createContainer(in: page2)
		let text = createTitle("What college do you belong to?", in: container)
		
		let buttonsContainer = UIStackView.newAutoLayout()
		container.addSubview(buttonsContainer)
		buttonsContainer.autoPinEdge(.top, to: .bottom, of: text, withOffset: Layout.MARGIN)
		buttonsContainer.autoPinEdge(toSuperviewEdge: .left)
		buttonsContainer.autoPinEdge(toSuperviewEdge: .right)
		buttonsContainer.autoPinEdge(toSuperviewEdge: .bottom)
		
		buttonsContainer.alignment = .fill
		buttonsContainer.axis = .vertical
		buttonsContainer.spacing = 10
		let collegeButtons:[(button:UILabel, pk:Int?)] = Colleges.ORDERED.map({(button:createButton(with: $0.rawValue, textSize: 18), pk:$0.pk)})
		buttons.append(collegeButtons)
		collegeButtons.forEach({buttonsContainer.addArrangedSubview($0.button)})
		
		return page2
	}
	/**
		Creates the text & buttons for page 3, with listeners for on click events.
		Adds buttons to `buttons` as the 2nd element.
	
		Required: `createPage1()` and `creaetPage2()` has been run (once).
		- returns: the 3rd page.
	*/
	private func createPage3() -> UIViewController
	{
		let page3 = PageVC()
		
		let container = createContainer(in: page3)
		let text = createTitle("Welcome to Cornell Orientation Week!", in: container)
		
		let header1 = createHeader("Get There.", in: container)
		header1.autoPinEdge(.top, to: .bottom, of: text, withOffset: 42)
		let paragraph1 = createParagraph("Use your customized calendar to find events for your class and college.", in: container)
		paragraph1.autoPinEdge(.top, to: .bottom, of: header1, withOffset: 10)
		
		let header2 = createHeader("Explore.", in: container)
		header2.autoPinEdge(.top, to: .bottom, of: paragraph1, withOffset: Layout.MARGIN)
		let paragraph2 = createParagraph("Browse, search, and filter through orientation events to add to your calendar.", in: container)
		paragraph2.autoPinEdge(.top, to: .bottom, of: header2, withOffset: 10)
		
		let header3 = createHeader("Stay Informed.", in: container)
		header3.autoPinEdge(.top, to: .bottom, of: paragraph2, withOffset: Layout.MARGIN)
		let paragraph3 = createParagraph("Use your Orientation pamphlet for other important information and resources.", in: container)
		paragraph3.autoPinEdge(.top, to: .bottom, of: header3, withOffset: 10)
		
		let startButton = createButton(with: "Get Started", textSize: 24)
		container.addSubview(startButton)
		startButton.autoPinEdge(.top, to: .bottom, of: paragraph3, withOffset: 42)
		startButton.autoPinEdge(toSuperviewEdge: .left)
		startButton.autoPinEdge(toSuperviewEdge: .right)
		startButton.autoPinEdge(toSuperviewEdge: .bottom)
		
		buttons.append([(button:startButton, pk:nil)])
		
		return page3
	}
	/**
		Creates a `UIView` within the view of the given `UIViewController`
		- parameter vc: UIViewController
		- returns: Container (content view of scroll view)
	*/
	private func createContainer(in vc:UIViewController) -> UIView
	{
		let scrollView = UIScrollView.newAutoLayout()
		vc.view.addSubview(scrollView)
		scrollView.autoPinEdgesToSuperviewEdges()
		
		let container = UIView.newAutoLayout()
		scrollView.addSubview(container)
		container.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 40, left: Layout.MARGIN, bottom: 40, right: Layout.MARGIN))
		container.autoMatch(.width, to: .width, of: vc.view, withOffset: -Layout.MARGIN * 2)
		return container
	}
	/**
		Creates a `UILabel` with the style of a title containing the given text.
		The title's top, left, and right sides are pinned to the `container`.
		The label assumes it is the topmost child.
		- parameters:
			- title: label.text
			- container: label.superview
		- returns: Label
	*/
	private func createTitle(_ title:String, in container: UIView) -> UILabel
	{
		let text = UILabel.newAutoLayout()
		container.addSubview(text)
		text.font = UIFont(name: Font.BOLD, size: 28)
		text.text = title
		text.numberOfLines = 0
		text.autoPinEdge(toSuperviewEdge: .left)
		text.autoPinEdge(toSuperviewEdge: .right)
		text.autoPinEdge(toSuperviewEdge: .top)
		return text
	}
	/**
		Creates a `UILabel` with the style of a header containing the given text.
		The header's left and right sides are pinned to the `container`.
		- parameters:
			- header: label.text
			- container: label.superview
		- returns: Label
	*/
	private func createHeader(_ header:String, in container:UIView) -> UILabel
	{
		let text = UILabel.newAutoLayout()
		container.addSubview(text)
		text.font = UIFont(name: Font.BOLD, size: 18)
		text.text = header
		text.textColor = Colors.BRIGHT_RED
		text.numberOfLines = 0
		text.autoPinEdge(toSuperviewEdge: .left)
		text.autoPinEdge(toSuperviewEdge: .right)
		return text
	}
	/**
		Creates a `UILabel` with the style of a paragraph containing the given text.
		The label's left and right sides are pinned to the `container`.
		- parameters:
			- paragraph: label.text
			- container: label.superview
	-	 returns: Label
	*/
	private func createParagraph(_ paragraph:String, in container:UIView) -> UILabel
	{
		let text = UILabel.newAutoLayout()
		container.addSubview(text)
		text.font = UIFont(name: Font.MEDIUM, size: 16)
		text.text = paragraph
		text.numberOfLines = 0
		text.autoPinEdge(toSuperviewEdge: .left)
		text.autoPinEdge(toSuperviewEdge: .right)
		return text
	}
	/**
		Creates a button with the given text and font size, with a specific style
		and padding. Adds listeners for on-click events.
		- parameters:
			- text: Text in button.
			- textSize: Font size of text in button.
		- returns: Button, with on-click listener set to `onButtonClick()`
	*/
	private func createButton(with text:String, textSize:CGFloat) -> UILabel
	{
		let button = PaddedLabel.newAutoLayout()
		button.padding = UIEdgeInsets(top: textSize/2, left: 0, bottom: textSize/2, right: 0)
		button.layer.borderWidth = 2
		button.layer.borderColor = Colors.RED.cgColor
		button.layer.cornerRadius = 10
		button.layer.masksToBounds = true
		
		button.numberOfLines = 0
		button.text = text
		button.textColor = Colors.RED
		button.textAlignment = .center
		button.font = UIFont(name: Font.DEMIBOLD, size: textSize)
		
		button.isUserInteractionEnabled = true
		button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onButtonClick(_:))))
		return button
	}
	/**
		Handles button clicks.
		Fills the button that was clicked and empties other buttons on that pages.
		Saves the values for buttons that have a `pk` associated with it.
		Scrolls to the next page if it isn't the last page, or opens the main app.
	
		- parameter gestureRecognizer: Contains the view that was clicked.
	*/
	@objc func onButtonClick(_ gestureRecognizer: UIGestureRecognizer)
	{
		guard let clickedButton = gestureRecognizer.view as? UILabel else {
			print("InitialSettingsVC incorrect button click detected")
			return
		}
		
		for pageNum in 0..<buttons.count
		{
			if let index = buttons[pageNum].map({$0.button}).index(of: clickedButton)
			{
				//deselect all buttons
				buttons[pageNum].forEach({
					(button, _) in
					button.backgroundColor = UIColor.white
					button.textColor = Colors.RED
				})
				
				//select the clicked button
				clickedButton.backgroundColor = Colors.RED
				clickedButton.textColor = UIColor.white
				
				//save new values
				if let pk = buttons[pageNum][index].pk
				{
					switch pageNum
					{
					case 0:	//the 1st page stores the student's type
						studentTypePk = pk
					case 1:	//the 2nd page stores the student's college
						collegePk = pk
					default:
						print("InitialSettingsVC: onButtonClick called with pk on invalid page: \(pageNum)")
					}
				}
				
				//go to the next page
				if (pageNum < pages.count-1)
				{
					setViewControllers([pages[pageNum+1]], direction: .forward, animated: true, completion: nil)
				}
				else
				{
					attemptFinish()
				}
				return
			}
		}
	}
	/**
		Attempts to add the required events for the user and end the tutorial. Will stall until events are downloaded.
	
		Does not save the student type and the college type until the events are updated, otherwise if the app is closed while we're waiting for events to update, the next time the app is opened, it'll skip through the tutorial and no events will be added.
	*/
	private func attemptFinish()
	{
		if (UserData.version == 0)
		{
			waitingOnEventDownload = true
			showRetryDownloadAlert()
		}
		else
		{
			//set college types
			if (collegePk != nil)
			{
				UserData.setCollegeType(pk: collegePk!)
			}
			if (studentTypePk != nil)
			{
				UserData.setStudentType(pk: studentTypePk!)
			}
			
			//add required events
			UserData.allEvents.values.flatMap({$0})
				.filter({UserData.requiredForUser(event: $0)})
				.forEach({UserData.insertToSelectedEvents($0)})
			//send notifications
			LocalNotifications.updateNotifications()
			
			present(TabBarVC(), animated: true, completion: nil)
		}
	}
	
	/**
		Listens to events that indicate that an attempt to download events has completed. If `waitingOnEventDownload` is true, then the user has completed the tutorial but the events have yet to finish downloading. Tell the user and let him try again.
	*/
	@objc func onEventsReload()
	{
		if (waitingOnEventDownload)
		{
			//if version == 0, then we DON'T have any events downloaded
			UserData.version == 0 ? showRetryDownloadAlert() : attemptFinish()
		}
	}
	
	/**
		Shows an alert that allows the user to retry downloading events.
	*/
	private func showRetryDownloadAlert()
	{
		let alert = UIAlertController(title: "Error", message: "Orientation events could not be downloaded", preferredStyle: .alert)
		let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: {(action) in UserData.loadData()})
		alert.addAction(tryAgain)
		present(alert, animated: true, completion: nil)
	}
	
	//the following 2 methods are required to scroll through the pages
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
	//the following 2 methods are required to display UIPageControl
	func presentationCount(for pageViewController: UIPageViewController) -> Int
	{
		return pages.count
	}
	func presentationIndex(for pageViewController: UIPageViewController) -> Int
	{
		return 0
	}
}

/**
	Template page to use within a UIPageViewController.
*/
private class PageVC:UIViewController
{
	/**
		Give the view a background.
	*/
	override func viewDidLoad()
	{
		super.viewDidLoad()
		view.backgroundColor = UIColor.white
	}
}
