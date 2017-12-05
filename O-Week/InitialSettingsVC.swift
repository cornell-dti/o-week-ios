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
*/
class InitialSettingsVC:UIPageViewController, UIPageViewControllerDataSource
{
	var pages:[UIViewController]!
	var buttons:[[UILabel]] = []
	
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
		
		buttons.append([freshmanButton, transferButton])
		
		return page1
	}
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
		let collegeButtons = Colleges.ORDERED.map({createButton(with: $0.rawValue, textSize: 18)})
		buttons.append(collegeButtons)
		collegeButtons.forEach({buttonsContainer.addArrangedSubview($0)})
		
		return page2
	}
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
		
		buttons.append([startButton])
		
		return page3
	}
	private func createContainer(in vc:UIViewController) -> UIView
	{
		let container = UIView.newAutoLayout()
		vc.view.addSubview(container)
		container.autoPinEdge(toSuperviewEdge: .left, withInset: Layout.MARGIN)
		container.autoPinEdge(toSuperviewEdge: .right, withInset: Layout.MARGIN)
		container.autoCenterInSuperview()
		return container
	}
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
			if (buttons[pageNum].contains(clickedButton))
			{
				//deselect all buttons
				buttons[pageNum].forEach({
					button in
					button.backgroundColor = UIColor.white
					button.textColor = Colors.RED
				})
				
				//select the clicked button
				clickedButton.backgroundColor = Colors.RED
				clickedButton.textColor = UIColor.white
			}
		}
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
