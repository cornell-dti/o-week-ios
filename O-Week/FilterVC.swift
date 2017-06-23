//
//  FilterVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 6/12/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class FilterVC: UITableViewController
{
    let sections = ["", "By Category"]
    
    var selectedCell: FilterCell?
    
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
		case 0:
			return 2	//Show all events, show required events
		case 1:
			return UserData.categories.count
		default:
			print("FilterVC: unexpected section number: \(section)")
			return 0
		}
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") as! FilterCell
		switch (indexPath.section)
		{
		case 0:
			indexPath.row == 0 ? cell.configureAllEvents() : cell.configureRequiredEvents()
		case 1:
			cell.configure(category: UserData.categories[indexPath.row])
		default:
			print("FilterVC: Unexpected section number")
		}
        return cell
    }
    
    //Setting appearance of Section titles
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.white
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
        //TODO: implement filtering
        selectedCell?.selected(false)
        
        let cell = tableView.cellForRow(at: indexPath) as! FilterCell
		cell.selected(true)
        selectedCell = cell
    }
    
}
