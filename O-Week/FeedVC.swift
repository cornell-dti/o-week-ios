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
    
    // MARK:- Setup
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpExtendedNavBar()
        setUpHeightofFeedCell()
        setUpGestureRecognizers()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeed), name: .reload, object: nil)
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
    
    func handleTap(_ sender: UITapGestureRecognizer){
        //TODO: implement filtering functionality for selected date
        for i in 0..<views.count {
            if (views[i] == sender.view) {
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
        return UserData.allEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        cell.configure(event: UserData.allEvents[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = UserData.allEvents[indexPath.row]
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
