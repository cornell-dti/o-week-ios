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
	`tableSections`: Sections of cells. Each element has a name, which is the section's header, and rows, cells within the section.
	`selectedFilters`: All cells that are selected. Used to keep track of applied filters.
*/
class FilterVC: UITableViewController
{
	let showRequiredEventsCell = UITableViewCell.newAutoLayout()
	
	var tableSections = [(name:String, rows:[UITableViewCell])]()
	var selectedFilters:Set<UITableViewCell> = []
	
	/**
		Sets the table to `grouped` style, the title to "Filter", and creates the table view cells.
	*/
	convenience init()
	{
		self.init(style: .grouped)
		
		title = "Filter"
		configureTableSections()
	}
	/**
		Sets up the all cells in the table.
	*/
	private func configureTableSections()
	{
		showRequiredEventsCell.textLabel?.text = "Required events"
		
		tableSections.append((name: "", rows: [showRequiredEventsCell]))
		//put student types in 2nd section
		tableSections.append((name: "Students", rows: Student.ORDERED.map({
			student in
			let cell = UITableViewCell.newAutoLayout()
			cell.textLabel?.text = student.rawValue
			return cell
		})))
		//put colleges in 3rd section
		tableSections.append((name: "Colleges", rows: Colleges.ORDERED.map({
			college in
			let cell = UITableViewCell.newAutoLayout()
			cell.textLabel?.text = college.rawValue
			return cell
		})))
		//put all the categories that aren't colleges in the last section
		tableSections.append((name: "", rows: UserData.categories
			.filter({Colleges.collegeForPk($0.pk) == nil}).map({
				category in
				let cell = UITableViewCell.newAutoLayout()
				cell.textLabel?.text = category.name
				return cell
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
        return tableSections[indexPath.section].rows[indexPath.row]
    }
    /**
		Gives the selected cell a checkmark (or removes it) and notify listeners.
		- parameters:
			- tableView: Reference to table.
			- indexPath: Index of selected cell.
	*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
      	let cell = tableView.cellForRow(at: indexPath)!
		if (selectedFilters.contains(cell))
		{
			cell.accessoryType = .none
			selectedFilters.remove(cell)
		}
		else
		{
			cell.accessoryType = .checkmark
			selectedFilters.insert(cell)
		}
		tableView.deselectRow(at: indexPath, animated: true)
		NotificationCenter.default.post(name: .reloadData, object: nil)
    }
}
