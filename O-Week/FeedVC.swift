//
//  FeedVC.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 3/17/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class FeedVC:UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate
{
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var view0: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var label0: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    var views: [UIView] = []
    var labels: [UILabel] = []
    var selected: Int = 0 //index of date selected (0-4)
    
    //Temporary Data
    let data = [["7:45 AM", "8:45 AM", "Alumni Families and Legacy Reception", "Tent on Rawlings Green"],
                ["8:45 AM", "10:00 AM", "New Student Convocation", "Shoellkopf Stadium"],
                ["10:00 AM", "11:30 AM", "Tours of Libraries and Manuscript", "Upper Lobby, Uris Library"],
                ["10:00 AM", "6:00 PM", "Dump and Run Sale", "Helen Newman Hall"],
                ["10:30 AM", "11:30 AM", "AAP—Dean’s Convocation", "Abby and Howard Milstein Hall"],
                ["10:30 AM", "11:30 AM", "CALS—Dean’s Convocation", "Call Alumni Auditorium, Kennedy Hall"]]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpExtendedNavBar()
        setUpHeightofFeedCell()
        setUpNavBarViewsandLabels()
        setUpGestureRecognizers()
    }
    
    func setUpNavBarViewsandLabels(){
        views = [view0, view1, view2, view3, view4]
        labels = [label0, label1, label2, label3, label4]
        for view in views{
            view.layer.cornerRadius = 18 //half of width for a perfect circle
        }
        setUpNavBarViewsandLabelsWithSelected(selected: 0)
    }
    
    func setUpGestureRecognizers(){
        //clean up code later
        let gr0 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap0(_:)))
        let gr1 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap1(_:)))
        let gr2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))
        let gr3 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap3(_:)))
        let gr4 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap4(_:)))
        view0.addGestureRecognizer(gr0)
        view1.addGestureRecognizer(gr1)
        view2.addGestureRecognizer(gr2)
        view3.addGestureRecognizer(gr3)
        view4.addGestureRecognizer(gr4)
        view0.isUserInteractionEnabled = true
        view1.isUserInteractionEnabled = true
        view2.isUserInteractionEnabled = true
        view3.isUserInteractionEnabled = true
        view4.isUserInteractionEnabled = true
    }
    
    func handleTap0(_ sender: UITapGestureRecognizer) {
        setUpNavBarViewsandLabelsWithSelected(selected: 0)
        //TODO: implement button functionality for selected date
    }
    func handleTap1(_ sender: UITapGestureRecognizer) {
        setUpNavBarViewsandLabelsWithSelected(selected: 1)
        //TODO: implement button functionality for selected date
    }
    func handleTap2(_ sender: UITapGestureRecognizer) {
        setUpNavBarViewsandLabelsWithSelected(selected: 2)
        //TODO: implement button functionality for selected date
    }
    func handleTap3(_ sender: UITapGestureRecognizer) {
        setUpNavBarViewsandLabelsWithSelected(selected: 3)
        //TODO: implement button functionality for selected date
    }
    func handleTap4(_ sender: UITapGestureRecognizer) {
        setUpNavBarViewsandLabelsWithSelected(selected: 4)
        //TODO: implement button functionality for selected date
    }
    
    func setUpNavBarViewsandLabelsWithSelected(selected: Int){
        for index in 0...views.count - 1 {
            if(index == selected){
                views[index].backgroundColor = UIColor.white
                labels[index].textColor = UIColor.black
            }else{
                views[index].backgroundColor = Color.RED
                labels[index].textColor = UIColor.white
            }
        }
    }
    
    func setUpHeightofFeedCell(){
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = 86
    }
    
    func setUpExtendedNavBar(){
        navigationController?.navigationBar.shadowImage = UIImage(named: "transparent_pixel")
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pixel"), for: .default)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        let dataForCell = data[indexPath.row]
        cell.configure(title: dataForCell[2], caption: dataForCell[3], startTime: dataForCell[0], endTime: dataForCell[1])
        return cell
    }
    
}
