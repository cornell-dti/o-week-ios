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
    
    //MARK:- Properties
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet var views: [UIView]!
    @IBOutlet var labels: [UILabel]!

    var selected = 0 //index of date selected (0-4)
    
    // FIXME: Temporary Data
    let data = [Event(title:"Alumni Families and Legacy Reception", caption:"Tent on Rawlings Green", start:Time(hour:7, minute:45), end:Time(hour:8, minute:45)),
                Event(title:"New Student Convocation", caption:"Shoellkopf Stadium", start:Time(hour:8, minute:45), end:Time(hour:10, minute:0)),
                Event(title:"Tours of Libraries and Manuscript", caption:"Upper Lobby, Uris Library", start:Time(hour:10, minute:0), end:Time(hour:11, minute:30)),
                Event(title:"Dump and Run Sale", caption:"Helen Newman Hall", start:Time(hour:10, minute:0), end:Time(hour:18, minute:0)),
                Event(title:"AAP—Dean’s Convocation", caption:"Abby and Howard Milstein Hall", start:Time(hour:10, minute:30), end:Time(hour:11, minute:30)),
                Event(title:"CALS—Dean’s Convocation", caption:"Call Alumni Auditorium, Kennedy Hall", start:Time(hour:10, minute:30), end:Time(hour:11, minute:30))]
    
    // MARK:- Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpExtendedNavBar()
        setUpHeightofFeedCell()
        setUpGestureRecognizers()
    }
    
    func setUpGestureRecognizers(){
        for view in views {
            let gr = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            view.addGestureRecognizer(gr)
            view.isUserInteractionEnabled = true
        }
    }
    
    func setUpHeightofFeedCell(){
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = 86
    }
    
    func setUpExtendedNavBar(){
        navigationController?.navigationBar.shadowImage = UIImage(named: "transparent_pixel")
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pixel"), for: .default)
        for view in views{
            view.layer.cornerRadius = view.frame.width / 2 //half of width for a perfect circle
        }
        changeSelectedDate(to: 0)
    }
    
    // MARK:- Date Actions
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        //TODO: implement filtering functionality for selected date
        for i in 0..<views.count
        {
            if (views[i] == sender.view)
            {
                changeSelectedDate(to: i)
                break
            }
        }
    }
    
    func changeSelectedDate(to selected: Int){
        //revert last selected date
        views[self.selected].backgroundColor = Color.RED
        labels[self.selected].textColor = UIColor.white
        //set new selected date
        views[selected].backgroundColor = UIColor.white
        labels[selected].textColor = UIColor.black
        
        self.selected = selected
    }
    
    // MARK:- Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        cell.configure(event: data[indexPath.row])
        return cell
    }
    
}
