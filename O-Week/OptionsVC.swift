//
//  OptionsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class OptionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var setting: (settingWOptions: Constants.Setting, stored_val: String?)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableViewAppearance()
        self.navigationItem.title = setting!.settingWOptions.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        switch setting!.settingWOptions.name {
        case Constants.setForSetting.name:
            LocalNotifications.setForSetting = setting!.stored_val
        case Constants.notifyMeSetting.name:
            LocalNotifications.notifyMeSetting = setting!.stored_val
        default:
            print("Error with switch statement in OptionsVC viewWillDisappear")
        }
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
    }
    
    func setUpTableViewAppearance(){
        //Removes gray background from TableView's grouped style
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    // MARK:- TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setting!.settingWOptions.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell") as! OptionsCell
        cell.label.text = setting!.settingWOptions.options[indexPath.row]
        if(setting!.stored_val == setting!.settingWOptions.options[indexPath.row]){
            cell.view.backgroundColor = Constants.Colors.RED
        } else {
            cell.view.backgroundColor = UIColor.white
        }
        cell.view.layer.cornerRadius = cell.view.frame.width / 2
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setting!.stored_val = setting!.settingWOptions.options[indexPath.row]
        tableView.reloadData()
    }
    
}
