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
    
    var setting: UserPreferences.NotificationSetting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableViewAppearance()
        self.navigationItem.title = setting!.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        switch setting!.name {
        case UserPreferences.setForSetting.name:
            UserPreferences.setForSetting.chosen = setting!.chosen
        case UserPreferences.notifyMeSetting.name:
            UserPreferences.notifyMeSetting.chosen = setting!.chosen
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
        return setting!.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell") as! OptionsCell
        cell.label.text = setting!.options[indexPath.row]
        if(setting!.chosen == setting!.options[indexPath.row]){
            cell.view.backgroundColor = Constants.Colors.RED
        } else {
            cell.view.backgroundColor = UIColor.white
        }
        cell.view.layer.cornerRadius = cell.view.frame.width / 2
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setting!.chosen = setting!.options[indexPath.row]
        tableView.reloadData()
    }
    
}
