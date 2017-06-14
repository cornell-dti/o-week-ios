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
    
    
    let settings: [(name: String, options: [String])] = [(name: "Set for...", options: ["All my events", "Only required events"]), (name: "Notify me...", options: ["At time of event", "1 hour before", "2 hours before", "3 hours before", "5 hours before", "Morning of (7 am)", "1 day before", "2 days before"])]
    //let actions = ["Add all required events to my schedule" ,"Remove all events from my schedule"]
    //var settings: [(name: String, options: [String])] = []
    
    var defaults: UserDefaults?
    var chosenSetting: Int?
    var hideSettings = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = UserDefaults.standard
        setUpTableViewAppearance()
        displaySettings()
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: .reloadSettings, object: nil)
    }
    
    func setUpTableViewAppearance(){
        //Removes gray background from TableView's grouped style
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    func displaySettings(){
        setForOption.text = defaults!.string(forKey: Constants.Settings.setFor.rawValue)
        notifyMeOption.text = defaults?.string(forKey: Constants.Settings.notifyMe.rawValue)
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if(!sender.isOn) {
            defaults?.set("No events", forKey: Constants.Settings.setFor.rawValue)
        }
        hideSettings = !sender.isOn
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
            dest.setting = settings[chosenSetting! - 1]
        }
    }
    
    // MARK:- Helper Functions
    
    func updateSettings(){
        displaySettings()
        tableView.reloadData()
    }
    
}
