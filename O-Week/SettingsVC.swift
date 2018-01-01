//
//  SettingsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Displays settings to the user and a list of links to external resources.

	`URLS`: URLs matching each cell in the resources section. Should be updated often.
	`tableSections`: Sections of cells in Settings. Each element has a name, which is the section's header, and rows, cells within the section.
*/
class SettingsVC: UITableViewController
{
	let remindersCell = UITableViewCell.newAutoLayout()
	let notifyMeCell = UITableViewCell.newAutoLayout()
	
	let orientationPdf = UITableViewCell.newAutoLayout()
	let campusMap = UITableViewCell.newAutoLayout()
	let orientationWebsite = UITableViewCell.newAutoLayout()
	let rescuerApp = UITableViewCell.newAutoLayout()
	let URLS = ["http://ccengagement.cornell.edu/sites/ccengagement.cornell.edu/files/rnsp/documents/january_orientation_guide_2018.pdf", "https://www.cornell.edu/about/maps/cornell-campus-map-2015.pdf", "https://newstudents.cornell.edu/spring-2018/first-year/orientation", "itms-apps://itunes.apple.com/us/app/cornell-rescuer/id1209164387?mt=8"]
	
	lazy var tableSections = [(name:"Notifications", rows:[remindersCell, notifyMeCell]), (name:"Resources", rows:[orientationPdf, campusMap, orientationWebsite, rescuerApp])]
	
    let remindersSwitch = UISwitch.newAutoLayout()
    let notifyMeOption = UILabel.newAutoLayout()
	
	var didLayout = false
	
	/**
		Create a `SettingsVC` with a NavigationController as its parent and its title 	set.
		- returns: NavigationController with a `SettingsVC` child.
	*/
	static func createWithNavBar() -> UINavigationController
	{
		let navController = UINavigationController(rootViewController: SettingsVC())
		navController.navigationBar.topItem?.title = "Settings"
		return navController
	}
	/**
		Create a grouped table view.
	*/
	convenience init()
	{
		self.init(style: .grouped)
	}
	/**
		Set up table view appearance, link saved values to displayed settings.
	*/
    override func viewDidLoad()
	{
        super.viewDidLoad()
		configureCells()
		
		let remindersOn = BoolPreference.Reminder.isTrue()
		remindersSwitch.setOn(remindersOn, animated: false)
        notifyMeOption.text = ListPreference.NotifyTime.get().rawValue
		disableNotifyme(!remindersOn)
    }
	private func configureCells()
	{
		guard !didLayout else {
			return
		}
		didLayout = true
		
		//
		// Reminders			[switch]
		//
		remindersCell.textLabel?.text = BoolPreference.Reminder.rawValue
		remindersCell.contentView.addSubview(remindersSwitch)
		remindersSwitch.autoPinEdge(toSuperviewMargin: .right)
		remindersSwitch.autoAlignAxis(toSuperviewAxis: .horizontal)
		remindersSwitch.addTarget(self, action: #selector(switchChanged), for: .touchUpInside)
		
		//
		// Notify me…		1 hour before
		//
		notifyMeCell.textLabel?.text = ListPreference.NotifyTime.rawValue
		notifyMeCell.contentView.addSubview(notifyMeOption)
		notifyMeOption.autoPinEdge(toSuperviewMargin: .right)
		notifyMeOption.autoAlignAxis(toSuperviewAxis: .horizontal)
		notifyMeOption.textAlignment = .right
		notifyMeOption.font = UIFont.systemFont(ofSize: 14)
		notifyMeOption.alpha = 0.6
		notifyMeOption.text = ListPreference.NotifyTime.get().rawValue
		
		//Resources
		orientationPdf.textLabel?.text = "Orientation PDF"
		campusMap.textLabel?.text = "Campus Map"
		orientationWebsite.textLabel?.text = "New Students Orientation Website"
		rescuerApp.textLabel?.text = "Cornell Rescuer App"
	}
	
    // MARK:- Actions
	
	/**
		Listener to a change in the "reminder" switch. Save new data, disabling `notifyMeCell` if the switch if set to off.
	*/
	@objc func switchChanged()
	{
		BoolPreference.Reminder.set(remindersSwitch.isOn)
        LocalNotifications.updateNotifications()
		disableNotifyme(!remindersSwitch.isOn)
    }
    
    // MARK:- TableView Methods
	
	//the following methods should NOT be changed; change `tableSecgtions` instead.
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return tableSections.count
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		return tableSections[section].name
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return tableSections[section].rows.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		return tableSections[indexPath.section].rows[indexPath.row]
	}
	/**
		Perform different actions based on the selected cell.
		1. Reminders: Change reminders switch
		2. Notify me: Show notify time options
		3. Resources: Open website links
		- parameters:
			- tableView: Reference to table.
			- indexPath: IndexPath of selected cell.
	*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		switch (indexPath.section, indexPath.row)
		{
		case (0, 0):	//selected reminders
			remindersSwitch.setOn(!remindersSwitch.isOn, animated: true)
			switchChanged()
			tableView.deselectRow(at: indexPath, animated: true)
		case (0, 1):	//selected notify me
			showNotifyMeActionSheet()
			//deselect row w/o animation, otherwise action sheet takes a long time to show up
			tableView.deselectRow(at: indexPath, animated: false)
		case let (1, row):	//selected something in resources
			tableView.deselectRow(at: indexPath, animated: true)
			if let url = URL(string: URLS[row])
			{
				UIApplication.shared.open(url)
			}
		default:
			print("SettingsVC: tableview unknown indexPath selected: \(indexPath)")
		}
    }
	
	/**
		Shows an action sheet with all the options for what time to notify the user before an event starts. Includes a dismissable cancel button. If an option is selected, `notifyMeOption` is updated with the new selection, the new selection is saved, and notifications are updated.
	*/
    private func showNotifyMeActionSheet()
	{
		let actionSheet = UIAlertController(title: nil, message: ListPreference.NotifyTime.rawValue, preferredStyle: .actionSheet)
		ListPreference.OPTIONS[.NotifyTime]?.forEach({
			option -> () in
			let action = UIAlertAction(title: option.rawValue, style: .default, handler: {
				_ in
				self.notifyMeOption.text = option.rawValue
				ListPreference.NotifyTime.set(option)
				LocalNotifications.updateNotifications()
			})
			actionSheet.addAction(action)
		})
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(actionSheet, animated: true, completion: nil)
	}
	/**
		Disables/enables `notifyMeCell` based on the parameter. Changes color of its text to reflect changes.
		- important: This assumes all subviews of the cell are `UILabel`s. The app will crash otherwise.
		- parameter disable: True to disable `notifyMeCell`, False to enable it.
	*/
	private func disableNotifyme(_ disable:Bool)
	{
		notifyMeCell.isUserInteractionEnabled = !disable
		notifyMeCell.contentView.subviews.map({$0 as! UILabel}).forEach({$0.textColor = disable ? Colors.GRAY : UIColor.black})
	}
}
