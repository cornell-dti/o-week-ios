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
	
	var events = [Event]()
    var selectedEvent: Event? = nil
    var datePickerController: DatePickerController?
    
    let FEED_TABLEVIEW_ROW_HEIGHT:CGFloat = 86
    
    // MARK:- Setup
    
    override func viewDidLoad()
	{
        super.viewDidLoad()
        
        AppDelegate.setUpExtendedNavBar(navController: navigationController)
        setUpHeightofFeedCell()
        setNotificationListener()
		filter()
		scrollToNextEvent()
        
        datePickerController = DatePickerController(collectionView: collectionView)
    }
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		//sync date in case ScheduleVC changed it
		datePickerController?.syncSelectedDate()
	}
    
    func setUpHeightofFeedCell()
	{
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = FEED_TABLEVIEW_ROW_HEIGHT
    }
    
    // MARK:- Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        cell.configure(event: events[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "showEventDetails", sender: self)
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
        if (segue.identifier == "showEventDetails")
		{
            if let destination = segue.destination as? DetailsVC {
                destination.event = selectedEvent
            }
        }
    }
    
    // MARK:- Handle Updates
    
    private func setNotificationListener()
	{
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeed), name: .reloadData, object: nil)
    }
    func updateFeed()
	{
		filter()
        feedTableView.reloadData()
	}
	
	private func filter()
	{
		var tempEvents = UserData.allEvents[UserData.selectedDate]!
		if (FilterVC.filterRequired)
		{
			tempEvents = tempEvents.filter({$0.required})
		}
		else if (FilterVC.filterCategory != nil)
		{
			tempEvents = tempEvents.filter({$0.category == FilterVC.filterCategory!.pk})
		}
		
		events = tempEvents
	}
	
	private func scrollToNextEvent()
	{
		let date = Date()
		let now = Time()
		
		guard UserData.userCalendar.compare(date, to: UserData.selectedDate!, toGranularity: .day) == .orderedSame else {
			return
		}
		
		for i in 0..<events.count
		{
			let event = events[i]
			if (event.startTime >= now)
			{
				feedTableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .top, animated: false)
				return
			}
		}
	}
}
