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
    
    let sections = ["", "By College", "Other"]
    let filters = [["Show All Events"],
                   ["College of Agriculture and Life Sciences", "College of Architecture, Art and Planning", "College of Arts and Sciences", "College of Business", "College of Engineering", "College of Human Ecology", "School of Industrial and Labor Relations"],
                   ["International Students", "Transfer Students"]]
    
    var selectedCell: FilterCell?
    
    // MARK:- TableView Methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") as! FilterCell
        cell.label.text = filters[indexPath.section][indexPath.row]
        cell.label.layer.borderColor = Constants.Colors.GRAY.cgColor
        cell.label.layer.borderWidth = 1
        return cell
    }
    
    //Setting appearance of Section titles
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.white
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: implement filtering
        selectedCell?.label.backgroundColor = UIColor.white
        selectedCell?.label.textColor = Constants.Colors.GRAY_FILTER
        selectedCell?.label.layer.borderWidth = 1
        
        let cell = tableView.cellForRow(at: indexPath) as! FilterCell
        cell.label.backgroundColor = Constants.Colors.RED
        cell.label.textColor = UIColor.white
        cell.label.layer.borderWidth = 0
        selectedCell = cell
    }
    
}
