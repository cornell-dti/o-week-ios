//
//  FeedVC.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 3/17/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class FeedVC:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    //MARK:- Properties
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedEvent: Event? = nil
    var datePickerController: DatePickerController?
    
    let FEED_TABLEVIEW_ROW_HEIGHT:CGFloat = 86
    
    // MARK:- Setup
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        AppDelegate.setUpExtendedNavBar(navController: navigationController)
        setUpHeightofFeedCell()
        setNotificationListener()
        
        datePickerController = DatePickerController(collectionView: collectionView)
    }
    
    func setUpHeightofFeedCell(){
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = FEED_TABLEVIEW_ROW_HEIGHT
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
    
    // MARK:- Handle Updates
    
    func setNotificationListener(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeed), name: .reload, object: nil)
    }
    
    func updateFeed(){
        feedTableView.reloadData()
    }
}
