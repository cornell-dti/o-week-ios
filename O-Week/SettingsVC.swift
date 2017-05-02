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
    
    let sectionTitles = ["Notifications", "Events"]
    let actions = ["Add all events to my schedule", "Add all required events to my schedule" ,"Remove all events from my schedule"]
    
    var settings: [Setting] = []
    var chosenSetting: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableViewAppearance()
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: .reloadSettings, object: nil)
        settings = UserData.allSettings
    }
    
    func setUpTableViewAppearance(){
        //Removes gray background from TableView's grouped style
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    // MARK:- TableView Methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return settings.count
        } else {
            return actions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell
        if(indexPath.section == 0){
            cell.label.text = settings[indexPath.row].name
            cell.chosenOption.text = settings[indexPath.row].chosenOption!
        } else {
            cell.label.text = actions[indexPath.row]
            cell.chosenOption.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        //Setting appearance of Section titles
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        header.textLabel?.textColor = Color.RED
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            dest.navTitle = settings.remove(at: chosenSetting!).name
            dest.setting = UserData.allSettings.remove(at: chosenSetting!)
        }
    }
    
    // MARK:- Helper Functions
    
    func updateSettings(){
        settings = UserData.allSettings
        tableView.reloadData()
    }
    
}
