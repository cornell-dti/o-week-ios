//
//  FilterVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/12/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Displays a list of categories for the user to filter events in `FeedVC`.

	`selectedCell`: The cell currently selected by the user. Saved so we can animate it being unselected in the future.
	`filterRequired`: True if the user wants to show required events only.
	`filterCategory`: The category that the user wants to filter by. Will be nil if `filterRequired` is true or if the user wants to show all events.
*/
class FilterVC: UITableViewController
{
    let sections = ["", "By Category"]
	let ROW_FILTER_ALL = 0
	let ROW_FILTER_REQUIRED = 1
	let SECTION_DEFAULT = 0
	let SECTION_CATEGORIES = 1
    
    var selectedCell: FilterCell?
	
	//filtering types for FeedVC to inspect
	static var filterRequired = false
	static var filterCategory:Category?
    
    // MARK:- TableView Methods
	
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
        return sections[section]
    }
    override func numberOfSections(in tableView: UITableView) -> Int
	{
        return sections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch (section)
		{
		case SECTION_DEFAULT:
			return 2	//Show all events, show required events
		case SECTION_CATEGORIES:
			return UserData.categories.count
		default:
			print("FilterVC: unexpected section number: \(section)")
			return 0
		}
    }
	/**
		Set how each cell looks based on whether or not they are selected. The cell displays custom text if it represents special built-in filters (that are not categories).
		- parameters:
			- tableView: Reference to the table.
			- indexPath: Index & section of the cell.
	*/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") as! FilterCell
		
		//set selection here as well, since we want FilterVC to "remember" which filter was selected even after you exit FilterVC and reopen it
		let selected:Bool
		switch (indexPath.section)
		{
		case SECTION_DEFAULT:
			if (indexPath.row == ROW_FILTER_ALL)
			{
				cell.configureAllEvents()
				selected = !FilterVC.filterRequired && FilterVC.filterCategory == nil
			}
			else
			{
				cell.configureRequiredEvents()
				selected = FilterVC.filterRequired && FilterVC.filterCategory == nil
			}
		case SECTION_CATEGORIES:
			cell.configure(category: UserData.categories[indexPath.row])
			selected = !FilterVC.filterRequired && FilterVC.filterCategory != nil && FilterVC.filterCategory! == UserData.categories[indexPath.row]
		default:
			print("FilterVC: Unexpected section number")
			selected = false
		}
		
		cell.selected(selected)
		if (selected)
		{
			selectedCell = cell
		}
		
        return cell
    }
    
    /**
		Sets appearance of section titles.
		- parameters:
			- tableView: Reference to table.
			- view: Header.
			- section: Section number. Starts from 0.
	*/
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.white
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
    }
    /**
		Set the correct global variables when a filter is selected, and notify listeners. Deselects the previously selected cell (if that exists).
		- parameters:
			- tableView: Reference to table.
			- indexPath: Index of selected cell.
	*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
        selectedCell?.selected(false)
        
        let cell = tableView.cellForRow(at: indexPath) as! FilterCell
		cell.selected(true)
        selectedCell = cell
		
		//change static vars indicating what to filter
		if (cell.requiredEvents)
		{
			FilterVC.filterRequired = true
			FilterVC.filterCategory = nil
		}
		else
		{
			FilterVC.filterRequired = false
			if (cell.category != nil)
			{
				FilterVC.filterCategory = cell.category
			}
			else
			{
				FilterVC.filterCategory = nil
			}
		}
		NotificationCenter.default.post(name: .reloadData, object: nil)
    }
    
}
