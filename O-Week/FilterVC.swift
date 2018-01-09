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
	`tableSections`: Sections of cells. Each element has a name, which is the section's header, rows, cells within the section, and data, the data associated with the row.
	`selectedFilters`: All category pks that are selected. Used to keep track of applied filters.
*/
class FilterVC: UITableViewController
{
	let showRequiredEventsCell = UITableViewCell.newAutoLayout()
	
	var tableSections = [(name:String, rows:[(cell:UITableViewCell, data:HasPK?)])]()
	static var requiredFilter = false
	static var selectedFilters:Set<Int> = []
	
	/**
		Sets the table to `grouped` style, the title to "Filter", and creates the table view cells.
	*/
	convenience init()
	{
		self.init(style: .grouped)
		
		title = "Filter"
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(onCancelClick))
		configureTableSections()
	}
	/**
		Sets up the all cells in the table.
	*/
	private func configureTableSections()
	{
		showRequiredEventsCell.textLabel?.text = "Required events"
		
		tableSections.append((name: "", rows: [(cell: showRequiredEventsCell, data: nil)]))
		//put student types in 2nd section
		tableSections.append((name: "Students", rows: Student.ORDERED.map({
			student in
			let cell = UITableViewCell.newAutoLayout()
			cell.textLabel?.text = student.rawValue
			return (cell: cell, data: student)
		})))
		//put colleges in 3rd section
		tableSections.append((name: "Colleges", rows: Colleges.ORDERED.map({
			college in
			let cell = UITableViewCell.newAutoLayout()
			cell.textLabel?.text = college.rawValue
			return (cell: cell, data: college)
		})))
		//put all the categories that aren't colleges in the last section
		tableSections.append((name: "", rows: UserData.categories
			.filter({Colleges.collegeForPk($0.pk) == nil}).map({
				category in
				let cell = UITableViewCell.newAutoLayout()
				cell.textLabel?.text = category.name
				return (cell: cell, data: category)
			})))
	}
	
    // MARK:- TableView Methods
	
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
        return tableSections[section].name
    }
    override func numberOfSections(in tableView: UITableView) -> Int
	{
        return tableSections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return tableSections[section].rows.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        return tableSections[indexPath.section].rows[indexPath.row].cell
    }
    /**
		Gives the selected cell a checkmark (or removes it) and notify listeners.
		- parameters:
			- tableView: Reference to table.
			- indexPath: Index of selected cell.
	*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
      	let cellAndData = tableSections[indexPath.section].rows[indexPath.row]
		let cell = cellAndData.cell
		
		//check if the cell is the "Required" special cell or just a category
		if let data = cellAndData.data
		{
			if (FilterVC.selectedFilters.contains(data.pk))
			{
				cell.accessoryType = .none
				FilterVC.selectedFilters.remove(data.pk)
			}
			else
			{
				cell.accessoryType = .checkmark
				FilterVC.selectedFilters.insert(data.pk)
			}
		}
		else
		{
			if (FilterVC.requiredFilter)
			{
				cell.accessoryType = .none
				FilterVC.requiredFilter = false
			}
			else
			{
				cell.accessoryType = .checkmark
				FilterVC.requiredFilter = true
			}
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		NotificationCenter.default.post(name: .reloadData, object: nil)
    }
	
	/**
		Called when the navigation bar's "Cancel" button is clicked. Removes all filters and notifies listeners.
	*/
	@objc func onCancelClick()
	{
		FilterVC.requiredFilter = false
		FilterVC.selectedFilters.removeAll()
		tableSections.forEach({$0.rows.forEach({$0.cell.accessoryType = .none})})
		NotificationCenter.default.post(name: .reloadData, object: nil)
	}
	/**
		Returns the events that should be displayed based on the user's selection of filters. To be used by classes that need to update their feeds.
		- parameter events: All the events that need to be filtered.
		- returns: The list of filtered events, in order.
	*/
	static func filter(_ events:[Event]) -> [Event]
	{
		//no filter active
		if (selectedFilters.isEmpty && !requiredFilter) {
			return events
		}
		
		return events.filter({
			event in
			if (requiredFilter && UserData.requiredForUser(event: event))
			{
				return true
			}
			return selectedFilters.contains(event.category)
		})
	}
}
