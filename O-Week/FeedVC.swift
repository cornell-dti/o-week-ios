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
    var selectedEvent: Event? = nil
    
    let FEED_TABLEVIEW_ROW_HEIGHT:CGFloat = 86
    
    // FIXME: Temporary Data
    
    let data = [Event(title:"Alumni Families and Legacy Reception", caption:"Tent on Rawlings Green", start:Time(hour:7, minute:45), end:Time(hour:8, minute:45), description: nil),Event(title:"New Student Convocation", caption:"Shoellkopf Stadium", start:Time(hour:8, minute:45), end:Time(hour:10, minute:0), description: "This will be your official welcome from university administrators, as well as from your student body president and other key student leaders in Schoellkopf Stadium. Note that it takes 30 minutes to walk to Schoellkopf Stadium from North Campus and 20 minutes from West Campus; plan accordingly."),Event(title:"Tours of Libraries and Manuscript", caption:"Upper Lobby, Uris Library", start:Time(hour:10, minute:0), end:Time(hour:11, minute:30), description: nil),Event(title:"Dump and Run Sale", caption:"Helen Newman Hall", start:Time(hour:10, minute:0), end:Time(hour:18, minute:0), description: nil),Event(title:"AAP—Dean’s Convocation", caption:"Abby and Howard Milstein Hall", start:Time(hour:10, minute:30), end:Time(hour:11, minute:30), description: nil),Event(title:"CALS—Dean’s Convocation", caption:"Call Alumni Auditorium, Kennedy Hall", start:Time(hour:10, minute:30), end:Time(hour:11, minute:30), description: nil)]
    
    //test data to make sure scheduleVC performs as expected
    //let data = [Event(title:"A", caption:"A", start:Time(hour:9, minute:30), end:Time(hour:10, minute:30), description: nil), Event(title:"B", caption:"B", start:Time(hour:10, minute:30), end:Time(hour:12, minute:0), description: nil), Event(title:"C", caption:"C", start:Time(hour:11, minute:45), end:Time(hour:15, minute:30), description: nil), Event(title:"D", caption:"D", start:Time(hour:12, minute:0), end:Time(hour:14, minute:0), description: nil), Event(title:"E", caption:"E", start:Time(hour:13, minute:30), end:Time(hour:14, minute:0), description: nil), Event(title:"F", caption:"F", start:Time(hour:14, minute:0), end:Time(hour:15, minute:40), description: nil), Event(title:"G", caption:"G", start:Time(hour:14, minute:30), end:Time(hour:15, minute:0), description: nil), Event(title:"H", caption:"H", start:Time(hour:15, minute:30), end:Time(hour:16, minute:0), description: nil), Event(title:"I", caption:"I", start:Time(hour:16, minute:0), end:Time(hour:16, minute:30), description: nil), Event(title:"J", caption:"J", start:Time(hour:15, minute:50), end:Time(hour:16, minute:40), description: nil), Event(title:"K", caption:"K", start:Time(hour:17, minute:0), end:Time(hour:17, minute:30), description: nil)]
    
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
        feedTableView.estimatedRowHeight = FEED_TABLEVIEW_ROW_HEIGHT
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = data[indexPath.row]
        performSegue(withIdentifier: "showEventDetails", sender: self)
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetails" {
            if let destination = segue.destination as? DetailsVC {
                destination.event = selectedEvent
            }
        }
    }
    
    func updateFeed(){
        feedTableView.reloadData()
    }
}
