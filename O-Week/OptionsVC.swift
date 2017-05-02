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
    
    //var navTitle: String?
    var setting: Setting?
    //var options: [String] = []
    
    var defaults: UserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableViewAppearance()
        self.navigationItem.title = setting!.name //Dynamically set title of view based on which setting was chosen in Settings View
        //options = setting!.allOptions
        defaults = UserDefaults.standard
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //UserData.allSettings.append(setting!)
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
        return setting!.allOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell") as! OptionsCell
        cell.label.text = setting!.allOptions[indexPath.row]
        if(setting!.allOptions[indexPath.row] == defaults?.string(forKey: setting!.name)){
            cell.view.backgroundColor = Color.RED
        } else {
            cell.view.backgroundColor = UIColor.white
        }
        cell.view.layer.cornerRadius = cell.view.frame.width / 2
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults?.set(setting!.allOptions[indexPath.row], forKey: setting!.name)
        tableView.reloadData()
    }
    
}
