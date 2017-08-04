//
//  SettingsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController{
    
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
    
    // MARK:- Actions
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if(!sender.isOn) {
            UserPreferences.setForSetting.chosen = nil
            UserPreferences.notifyMeSetting.chosen = nil
        }
        hideSettings = !sender.isOn
        displaySettings()
        tableView.reloadData()
        LocalNotifications.updateNotifications()
    }
    
    @IBAction func visitWebsite(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "http://www.cornellsatech.org")!)
    }
    
    @IBAction func addAllRequired(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Do you want to add all required events to your schedule?", preferredStyle: .actionSheet)
        let addAll = UIAlertAction(title: "Add All Required Events", style: .default, handler: {
            [weak self] (alert: UIAlertAction!) -> Void in
            UserData.allEvents.forEach({date, events in events.forEach({
                if $0.required {
                    UserData.insertToSelectedEvents($0)
                }
            })})
            NotificationCenter.default.post(name: .reloadData, object: nil)
            _ = self?.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            return
        })
        optionMenu.addAction(addAll)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func removeAll(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Do you want to remove all events from your schedule?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Remove All Events", style: .destructive, handler: {
            [weak self] (alert: UIAlertAction!) -> Void in
            UserData.selectedEvents.forEach({ (date, events) in
                UserData.selectedEvents[date] = []
            })
            NotificationCenter.default.post(name: .reloadData, object: nil)
            _ = self?.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            return
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
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
        LocalNotifications.updateNotifications()
    }
    
}
