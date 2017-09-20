//
//  FeedVC.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 3/17/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Displays a list of events, ordered chronologically.
*/
class FeedVC:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var feedTableView: UITableView!
	@IBOutlet weak var collectionView: UICollectionView! //Date picker
	
	var events = [Event]()
    var selectedEvent: Event? = nil
    var datePickerController: DatePickerController?
    
    static let FEED_TABLEVIEW_ROW_HEIGHT:CGFloat = 86
    
    // MARK:- Setup
	
	/**
		Sets up views, notification listeners, and events with the appropriate filter. Scrolls to the event that will be next chronologically.
	*/
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
	
	/**
		Resync data on reappearance.
		- parameter animated: Ignored.
	*/
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		datePickerController?.syncSelectedDate()
	}
	
	/**
		Sets row height of feed cells.
	*/
    private func setUpHeightofFeedCell()
	{
        feedTableView.rowHeight = UITableViewAutomaticDimension
        feedTableView.estimatedRowHeight = FeedVC.FEED_TABLEVIEW_ROW_HEIGHT
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
    /**
		Segue to `DetailsVC` with the selected event.
	
		- parameters:
			- tableView: Reference to the `UITableView` in which the `FeedCell` was selected. Should be identical to the global variable.
			- indexPath: Index of the cell that was selected.
	*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "showEventDetails", sender: self)
    }
    
    // MARK:- Navigation
	
	/**
		Called automatically before segues. Sets `DetailsVC.selectedEvent` to the event that the user has selected.
		- parameters:
			- segue: Contains data about segue.
			- sender: Ignored.
	*/
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
	
	/**
		Begin listening for events that will change what needs to be displayed. Specifically:
		1. Whether an event is selected (can be changed by `DetailsVC`)
		2. Which day we're showing (can be changed by `DatePickerController`)
		3. Content of events we're showing (can be changed by updates from `Internet`)
	*/
    private func setNotificationListener()
	{
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeed), name: .reloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movedToLaterDate), name: .reloadAfterMovedLater, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movedToEarlierDate), name: .reloadAfterMovedEarlier, object: nil)
    }
	/**
		Regather data from `UserData.allEvents`, filter, and reload the table.
	*/
    @objc func updateFeed()
	{
		filter()
        feedTableView.reloadData()
	}
	/**
		Like `updateFeed()`, but if the user selected a date LATER than the current date, then animate the table accordingly.
	*/
    @objc func movedToLaterDate()
    {
        filter()
        feedTableView.reloadSections([0], with: .left)
    }
	/**
	Like `updateFeed()`, but if the user selected a date EARLIER than the current date, then animate the table accordingly.
	*/
    @objc func movedToEarlierDate()
    {
        filter()
        feedTableView.reloadSections([0], with: .right)
    }
	/**
		Retrieve events from `UserData.allEvents`, then apply a filter according to `FilterVC`.
	
		- note: Inside the function, `tempEvents` is used because directly manipulating `events` may immediately impact `TableViewDataSource` methods and produce unexpected behavior.
	*/
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
	/**
		Scrolls the feed to the event that will occur next. Does nothing if all events today started before current time OR if today is not the date the user selected.
	*/
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
