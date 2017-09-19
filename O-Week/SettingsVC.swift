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
*/
class SettingsVC: UITableViewController
{
    @IBOutlet weak var remindersSet: UISwitch!
    @IBOutlet weak var notifyMeOption: UILabel!
	@IBOutlet weak var notifyMeCell: UITableViewCell!
	
	/**
		Set up table view appearance, link saved values to displayed settings.
	*/
    override func viewDidLoad()
	{
        super.viewDidLoad()
        setUpTableViewAppearance()
		
		remindersSet.setOn(BoolPreference.Reminder.isTrue(), animated: false)
        notifyMeOption.text = ListPreference.NotifyTime.get().rawValue
    }
	
	/**
		Removes gray background from TableView's grouped style
	*/
    func setUpTableViewAppearance()
	{
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
	
    // MARK:- Actions
	
	/**
		Listener to a change in the "reminder" switch. Save new data, disabling `notifyMeCell` if the switch if set to off.
		- parameter sender: Switch.
	*/
    @IBAction func switchChanged(_ sender: UISwitch)
	{
		BoolPreference.Reminder.set(sender.isOn)
        LocalNotifications.updateNotifications()
		disableNotifyme(!sender.isOn)
    }
    /**
		Listener to buttons that will redirect the user to an external site/app.
		- parameter sender: Button that was selected. Should have its tag set in Storyboard.
	*/
    @IBAction func visitWebsite(_ sender: UIButton)
	{
        let url:String
        switch (sender.tag)
		{
        case 0: // Campus Map
            url = "https://www.cornell.edu/about/maps/cornell-campus-map-2015.pdf"
        case 1: // Official Orientation PDF
            url = "http://ccengagement.cornell.edu/sites/ccengagement.cornell.edu/files/a3c/cornell_orientation_guide_08_2017.pdf"
        case 2: // New Students Orientation Website
            url = "https://newstudents.cornell.edu/fall-2017/first-year/cornell-orientation-august-18-21-2017"
        case 3: // Cornell Rescuer App
            url = "itms-apps://itunes.apple.com/us/app/cornell-rescuer/id1209164387?mt=8"
        default:
			print("visitWebsite() called with unidentified sender")
            return
        }
        if let url = URL(string: url)
		{
            UIApplication.shared.open(url)
        }
    }
    
    // MARK:- TableView Methods
	/**
		Customize appearance of headers.
		- parameters:
			- tableView: Reference to table.
			- view: Header view.
			- section: Section header view belongs to.
	*/
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        header.textLabel?.textColor = Colors.RED
    }
	/**
		Show notify me options when the cell is selected.
		- parameters:
			- tableView: Reference to table.
			- indexPath: IndexPath of selected cell.
	*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
        if let notifyMeIndexPath = tableView.indexPath(for: notifyMeCell)
		{
			if (notifyMeIndexPath == indexPath)
			{
				showNotifyMeActionSheet()
				//deselect row w/o animation, otherwise action sheet takes a long time to show up
				tableView.deselectRow(at: indexPath, animated: false)
			}
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
