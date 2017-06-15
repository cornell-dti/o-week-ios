//
//  SettingsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var remindersSet: UISwitch!
    @IBOutlet weak var setForOption: UILabel!
    @IBOutlet weak var notifyMeOption: UILabel!
    
    var chosenSetting: UserPreferences.NotificationSetting?
    var hideSettings = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSwitch()
        setUpTableViewAppearance()
        displaySettings()
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: .reloadSettings, object: nil)
    }
    
    func setUpSwitch(){
        remindersSet.setOn(UserPreferences.setForSetting.chosen != nil, animated: false)
        hideSettings = !remindersSet.isOn
    }
    
    func setUpTableViewAppearance(){
        //Removes gray background from TableView's grouped style
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    func displaySettings(){
        setForOption.text = UserPreferences.setForSetting.chosen ?? "Not set"
        notifyMeOption.text = UserPreferences.notifyMeSetting.chosen ?? "Not set"
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if(!sender.isOn) {
            UserPreferences.setForSetting.chosen = nil
            UserPreferences.notifyMeSetting.chosen = nil
        }
        hideSettings = !sender.isOn
        displaySettings()
        tableView.reloadData()
    }
    
    // MARK:- TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return hideSettings ? 1 : 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        //Setting appearance of Section titles
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        header.textLabel?.textColor = Constants.Colors.RED
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row != 0){
            chosenSetting = indexPath.row == 1 ? UserPreferences.setForSetting : indexPath.row == 2 ? UserPreferences.notifyMeSetting : nil
            performSegue(withIdentifier: "toOptions", sender: self)
        } else {
            //TODO: Implement functionality for 2nd section (add all events, add all required, etc)
        }
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toOptions"){
            let dest = segue.destination as! OptionsVC
            dest.setting = chosenSetting
        }
    }
    
    // MARK:- Helper Functions
    
    func updateSettings(){
        displaySettings()
    }
    
}
