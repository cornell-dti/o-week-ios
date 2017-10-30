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
	`date`: Must be set by whomever instantiates this.
*/
class FeedVC:UITableViewController, DateContainer
{
	private(set) var date:Date!
	var events = [Event]()
    var selectedEvent: Event? = nil
	let FEED_CELL_ID = "feedCell"
    
    // MARK:- Setup
	
	/**
		Initialize FeedVC to the given date.
		- parameter date: Date this FeedVC will show events for.
	*/
	convenience init(date:Date)
	{
		self.init(nibName: nil, bundle: nil)
		self.date = date
	}
	
	/**
		Sets up views, notification listeners, and events with the appropriate filter. Scrolls to the event that will be next chronologically.
	*/
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		tableView.register(FeedCell.self, forCellReuseIdentifier: FEED_CELL_ID)
		makeSpaceForDatePicker()
        setNotificationListener()
		filter()
		scrollToNextEvent()
    }
	/**
		Creates space at the top of the table where the `DatePickerController` will be displayed.
	*/
	private func makeSpaceForDatePicker()
	{
		let topMargin = UIEdgeInsets(top: Layout.DATE_SIZE, left: 0, bottom: 0, right: 0)
		tableView.contentInset = topMargin
		tableView.scrollIndicatorInsets = topMargin
	}
	
    // MARK:- Table View Methods
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 80
	}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return events.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: FEED_CELL_ID, for: indexPath) as! FeedCell
        cell.configure(event: events[indexPath.row])
		cell.updateConstraintsIfNeeded()
        return cell
    }
    /**
		Segue to `DetailsVC` with the selected event.
	
		- parameters:
			- tableView: Reference to the `UITableView` in which the `FeedCell` was selected. Should be identical to the global variable.
			- indexPath: Index of the cell that was selected.
	*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    }
	/**
		Regather data from `UserData.allEvents`, filter, and reload the table.
	*/
    @objc func updateFeed()
	{
		filter()
        tableView.reloadData()
	}
	/**
		Retrieve events from `UserData.allEvents`, then apply a filter according to `FilterVC`.
	
		- note: Inside the function, `tempEvents` is used because directly manipulating `events` may immediately impact `TableViewDataSource` methods and produce unexpected behavior.
	*/
	private func filter()
	{
		var tempEvents = UserData.allEvents[date]!
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
		
		guard UserData.userCalendar.compare(date, to: self.date, toGranularity: .day) == .orderedSame else {
			return
		}
		
		for i in 0..<events.count
		{
			let event = events[i]
			if (event.startTime >= now)
			{
				tableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .top, animated: false)
				return
			}
		}
	}
}
