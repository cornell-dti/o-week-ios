//
//  OptionsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

class OptionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
	
	var settingType:ListPreference!
	var options:[ListPreference.Option]!
	var chosenOption:ListPreference.Option!
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
        setUpTableViewAppearance()
		
		guard settingType != nil else {
			fatalError("OptionsVC started without setting settingType")
		}
		
		self.navigationItem.title = settingType.rawValue
		options = ListPreference.OPTIONS[settingType]!
		chosenOption = settingType.get()
    }
    
    override func viewWillDisappear(_ animated: Bool)
	{
        NotificationCenter.default.post(name: .reloadSettings, object: nil)
    }
    
    func setUpTableViewAppearance()
	{
        //Removes gray background from TableView's grouped style
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    // MARK:- TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int
	{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return ListPreference.OPTIONS[settingType!]!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell") as! OptionsCell
        cell.label.text = options[indexPath.row].rawValue
        if (chosenOption == options[indexPath.row])
		{
            cell.view.backgroundColor = Colors.RED
        }
		else
		{
            cell.view.backgroundColor = UIColor.white
        }
        cell.view.layer.cornerRadius = cell.view.frame.width / 2
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		chosenOption = options[indexPath.row]
		settingType.set(chosenOption)
        tableView.reloadData()
    }
}
