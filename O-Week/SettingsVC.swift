//
//  SettingsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let section_titles = ["Notifications", "Events"]
    let data = [["Reminders set for" , "Notify me"],
                ["Add all events to my schedule", "Add all required events to my schedule" ,"Remove all events from my schedule"]]
    let tempCaptions = [["no events", "at time of event"],
                        ["","",""]]
    // Reminders set for - no events, all events, required events, custom?
    // Notify me - at time of event, 1 hour before, 2 hours before, 3 hours before, 5 hours before, morning of (7 am), 1 day before, 2 days before
    
    var chosenSetting: String?
    var chosenSettingsOptions: Int?
    var options = [ ["No events", "All events", "Required Events"],
                    ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "morning of (7 am)", "1 day before", "2 days before"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section_titles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell
        cell.label.text = data[indexPath.section][indexPath.row]
        cell.chosenOption.text = tempCaptions[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        header.textLabel?.textColor = Color.RED
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            chosenSetting = data[indexPath.section][indexPath.row]
            chosenSettingsOptions = indexPath.row
            performSegue(withIdentifier: "toOptions", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toOptions"){
            let dest = segue.destination as! OptionsVC
            dest.navTitle = chosenSetting
            dest.opts = options[chosenSettingsOptions!]
        }
    }
    
}
