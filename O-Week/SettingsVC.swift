//
//  SettingsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    let sectionTitles = ["Notifications", "Events"]
    let settings: [(name: String, options: [String])] = [(name: "Receive reminders for...", options: ["No events", "All my events", "Only required events"]), (name: "Notify me...", options: ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"])]
    let actions = ["Add all required events to my schedule" ,"Remove all events from my schedule"]
    
    //var settings: [(name: String, options: [String])] = []
    var chosenSetting: Int?
    
    var defaults: UserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableViewAppearance()
        defaults = UserDefaults.standard
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: .reloadSettings, object: nil)
    }
    
    func setUpTableViewAppearance(){
        //Removes gray background from TableView's grouped style
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    // MARK:- TableView Methods
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitles[section]
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sectionTitles.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(section == 0){
//            if(defaults!.string(forKey: Constants.Settings.receiveRemindersFor.rawValue) == "No events"){
//                return 1
//            }else {
//                return settings.count
//            }
//        } else {
//            return actions.count
//        }
//    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell
//        if(indexPath.section == 0){
//            cell.label.text = settings[indexPath.row].name
//            cell.chosenOption.text = defaults!.string(forKey: settings[indexPath.row].name)
//        } else {
//            cell.label.text = actions[indexPath.row]
//            cell.chosenOption.text = ""
//        }
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        //Setting appearance of Section titles
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        header.textLabel?.textColor = Constants.Colors.RED
        header.textLabel?.text = sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            chosenSetting = indexPath.row
            performSegue(withIdentifier: "toOptions", sender: self)
        } else {
            //TODO: Implement functionality for 2nd section (add all events, add all required, etc)
        }
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toOptions"){
            let dest = segue.destination as! OptionsVC
            dest.setting = settings[chosenSetting!]
        }
    }
    
    // MARK:- Helper Functions
    
    func updateSettings(){
        tableView.reloadData()
    }
    
}
