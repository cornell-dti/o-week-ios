//
//  ScheduleVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/18/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Displays `Event`s with height proportional to the event's length, laying them side by side should their times overlap.

	`collectionView`: Date picker
	`tableView`: Table of hours to the left of events. Should match to time lines.
	`contentView`: Holds all events and time lines. Direct child of `scrollView`. `UIScrollView`s should only have one child (its content), so this acts as a container for all events.
	`eventViews`: Holds a reference to each event view, so they can be destroyed on redraw. Each event view has its value as the corresponding event so the event can be passed to `DetailsVC` on click. Time lines are not redrawn so no reference to them is skept.
	`HOURS`: List of hours to display. Should be the full range of start/end times for events. Hours range: [START_HOUR, END_HOUR], inclusive. Hours wrap around, from 7~23, then 0~2.
	`START_HOUR`: The earliest hour an event can start.
	`END_HOUR`: The latest hour an event can end. Note that this is in AM; END_HOUR must < START_HOUR.
*/
class ScheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    var contentView: UIView!
	var eventViews = [UIView:Event]()
    
    var selectedEvent: Event?
    var datePickerController: DatePickerController?
    
	static let HOURS = {
		() -> [Time] in
		var hour = ScheduleVC.START_HOUR
		var hours = [Time]()
		while (hour != ScheduleVC.END_HOUR + 1)
		{
			hours.append(Time(hour: hour))
			hour += 1
			if (hour >= 24)
			{
				hour = 0
			}
		}
		return hours
	}()//Table view data
	static let START_HOUR = 7
	static let END_HOUR = 2
    let TITLE_CAPTION_MARGIN:CGFloat = 14
    let CONTAINER_RIGHT_MARGIN:CGFloat = 20
    let EVENT_CORNER_RADIUS:CGFloat = 5
    let EVENT_BORDER_WIDTH: CGFloat = 1
	
    // MARK:- Setup
	
	/**
		Set up nav bar and date picker, start listening for changes in events.
	*/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AppDelegate.setUpExtendedNavBar(navController: navigationController)
        setNotificationListener()
        
        datePickerController = DatePickerController()
    }
    /**
		Set up the scroll view and draw time lines and events.
	*/
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        scrollView.layoutIfNeeded()
        setUpContentView()
        drawTimeLines()
        drawAllEvents()
    }
    /**
		Sets up `contentView`, which is the primary child view of `scrollView`.
	*/
    private func setUpContentView()
	{
        let frame = scrollView.frame
        let newHeight = CGFloat(ScheduleVC.HOURS.count) * tableView.rowHeight
        let newFrame = CGRect(x:0, y: 0, width: frame.width, height: newHeight)
        
        contentView = UIView(frame: newFrame)
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSize(width: frame.width, height: newHeight)
    }
    /**
		Draw all the time lines, one line for each hour in `HOURS`.
	*/
    private func drawTimeLines()
	{
        for hour in ScheduleVC.HOURS
        {
            let line = UIView(frame: CGRect(x: 0, y: yForStartTime(hour), width: fullCellWidth(), height: 0.5))
            line.backgroundColor = Colors.GRAY
            contentView.addSubview(line)
        }
    }
    /**
		Draws all selected events in order.
	*/
    private func drawAllEvents()
	{
        //consider events that start earliest first
        let sortedEvents = UserData.selectedEvents[UserData.selectedDate!]!.sorted(by: {$0.startTime < $1.startTime})
        guard !sortedEvents.isEmpty else {
            return
        }
        
        _ = drawContainer(numSlots: 1, eventForSlot: [Int:Event](), events: sortedEvents)
    }
	/**
		Recursive function. Each iteration draws an event and adds it to `eventViews`.
		
		Terminology:
		Slot = column which events are assigned. Starts from 0.
		
		Specifically:
		1. Finds the best slot to put this event in based on conflicts with other events. If all available slots are full, creates a new slot. The slots in which events are placed are returned to earlier events in case its margins are updated (the new event shrinks the previous event's width when a new slot is created).
		2. Creates the event cell (`container`).
		3. If there are more events, calculate their slots too. If the new event won't overlap with this one, it automatically is assigned the entire width (numSlots = 1).
		4. Sets event margins, text, listener. Stores in appropriate data structures.
		5. Returns numSlots and eventForSlot to the parent with relevant new positioning info.
		
		- parameters:
			- numSlots: Number of slots currently available to events. Starts from 1.
			- eventForSlot: A map of events occupying a given slot. Note: slots CAN be empty (return nil).
			- events: The remaining events to position on screen.
		- returns: numSlots and eventForSlot to alert the previous event.
	*/
    func drawContainer(numSlots:Int, eventForSlot:[Int:Event], events:[Event]) -> (numSlots:Int, eventForSlot:[Int:Event])
	{
        let event = events.first!
        let slot = slotForEvent(event, numSlots: numSlots, eventForSlot: eventForSlot)
        
        var newNumSlots = numSlots
        var newEventForSlot = eventForSlot
        newEventForSlot[slot] = event
        
        //if this event was assigned to a slot equal to the current number of slots, resize the current number of slots
        if (slot == numSlots) {
            newNumSlots = slot + 1
        }
        //if there's a later event, process that before we can calculate the position of the current event
        if (events.count > 1) {
            let nextEvent = events[1]
            if (areEventOverlaps(nextEvent, numSlots: newNumSlots, eventForSlot: newEventForSlot)) {
                let recursiveData = drawContainer(numSlots: newNumSlots, eventForSlot: newEventForSlot, events: Array(events.dropFirst()))
                newNumSlots = recursiveData.numSlots
                newEventForSlot = recursiveData.eventForSlot
            }
            else {
                _ = drawContainer(numSlots: 1, eventForSlot: [Int:Event](), events: Array(events.dropFirst()))
            }
        }
        
        let container = UIView(frame: CGRect(x: cellX(slot: slot, numSlots: newNumSlots), y: yForStartTime(event.startTime), width: cellWidth(event: event, slot: slot, numSlots: newNumSlots, eventForSlot: newEventForSlot), height: cellHeight(event: event)))
        container.backgroundColor = Colors.RED
        container.layer.cornerRadius = EVENT_CORNER_RADIUS
        container.layer.borderColor = UIColor.white.cgColor
        container.layer.borderWidth = EVENT_BORDER_WIDTH
        contentView.addSubview(container)
        eventViews[container] = event
        drawTitleAndCaptionFor(container, event:event)
        //add gesture recognizer to container to segue to Details VC
        let gr = UITapGestureRecognizer(target: self, action: #selector(self.eventClicked(_:)))
        container.addGestureRecognizer(gr)
        container.isUserInteractionEnabled = true
        
        //the parent event wants to know if any new events have been added to the right of it, but not beneath it. Therefore, only let the parent know of slots that are added, not replaced. This way it expands to the right by the correct value.
        var parentEventForSlot = eventForSlot
        for slot in newEventForSlot.keys {
            if (canUseSlot(slot, event: event, eventForSlot: parentEventForSlot)) {
                parentEventForSlot[slot] = newEventForSlot[slot]
            }
        }
        return (numSlots:newNumSlots, eventForSlot:parentEventForSlot)
    }
    /**
		Draws event title and caption, setting up margins within the given container.
		- parameters:
			- container: View that the event is displayed as.
			- event: Event whose info is displayed.
	*/
    func drawTitleAndCaptionFor(_ container:UIView, event:Event)
	{
        //First subview of "container" must be UILabel corresponding to Title for eventClicked func to work
        let title = UILabel()
        title.numberOfLines = 0
        title.lineBreakMode = .byTruncatingTail
        title.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        title.textColor = UIColor.white
        title.text = event.title
        title.translatesAutoresizingMaskIntoConstraints = false
        //title.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        //title.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)*/
        
        container.addSubview(title)
        
        let caption = UILabel()
        caption.numberOfLines = 0
        caption.lineBreakMode = .byTruncatingTail
        caption.font = UIFont(name: "AvenirNext-Regular", size: 10)
        caption.textColor = UIColor.white
        caption.text = event.caption
        caption.translatesAutoresizingMaskIntoConstraints = false
        //caption.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        //caption.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        container.addSubview(caption)
        
        let titleHoriz = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[title]-(margin)-|", options: [], metrics: ["margin":TITLE_CAPTION_MARGIN], views: ["title":title])
        let captionHoriz = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(margin)-[caption]-(margin)-|", options: [], metrics: ["margin":TITLE_CAPTION_MARGIN], views: ["caption":caption])
        let vert = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(14@750)-[title]-0-[caption]-(>=14)-|", options: [], metrics: nil, views: ["title":title, "caption":caption])
        
        container.addConstraints(titleHoriz)
        container.addConstraints(captionHoriz)
        container.addConstraints(vert)
    }
	/**
		Distance from the top for a given view based on its start time. The view should either be an event view or a time line.
		- parameter startTime: The start time of the event view or time line.
		- returns: Y position.
	*/
	private func yForStartTime(_ startTime:Time) -> CGFloat
	{
		let timeFrom7 = minutesBetween(Time(hour: ScheduleVC.START_HOUR), and: startTime)
		return CGFloat(timeFrom7) * tableView.rowHeight / 60 + (tableView.rowHeight / 2)
	}
	/**
		Distance from the left for a given event view based on its slot and the total number of slots.
	
		As `numSlots` increases, width decreases. `slot` then determines which column the event view is placed in.
		- parameters:
			- slot: The slot the event view is placed in.
			- numSlots: The current # of slots assigned to events.
		- returns: X position.
	*/
	private func cellX(slot:Int, numSlots:Int) -> CGFloat
	{
		return fullCellWidth() / CGFloat(numSlots) * CGFloat(slot)
	}
	/**
		Returns the best slot for a given event based on the events that were already placed.
	
		- important: The leftmost unoccupied slot will be chosen, unless all slots are occupied, in which case the slot returned will be **OUT OF RANGE**.
	
		- parameters:
			- event: The event that we want to find a slot for.
			- numSlots: The current # of slots assigned to events. The more slots, the skinnier the
			events will appear. numSlot = 1 means each event takes up the entire width.
			- eventForSlot: The events that are currently assigned to each slot.
		- returns: The best slot to put this event in.
	*/
	private func slotForEvent(_ event:Event, numSlots:Int, eventForSlot:[Int:Event]) -> Int
	{
		for i in 0..<numSlots
		{
			if (canUseSlot(i, event: event, eventForSlot: eventForSlot))
			{
				return i
			}
		}
		return numSlots
	}
	/**
		Returns false if the given event can fit into every available slot. That means the event should
		be placed below, not next to, the current available events.
		
		- parameters:
			- event: The event that we test every slot's event against.
			- numSlots: The current # of slots assigned to events.
			- eventForSlot: The events that are currently assigned to each slot.
		- returns: True if there exists a slot that this event cannot use.
	*/
	private func areEventOverlaps(_ event:Event, numSlots:Int, eventForSlot:[Int:Event]) -> Bool
	{
		for i in 0..<numSlots
		{
			if (!canUseSlot(i, event: event, eventForSlot: eventForSlot))
			{
				return true
			}
		}
		return false
	}
	/**
		Returns how wide an event should be based on the number of slots and whether or not there are events to the right of this one that this would conflict with. An event will attempt to occupy all available space to its right.
		
		- parameters:
			- event: The event to determine the widthPercent for.
			- slot: The slot the event occupies.
			- numSlots: The current # of slots assigned to events.
			- eventForSlot: The events that are currently assigned to each slot.
		- returns: The width of the event view.
	*/

	private func cellWidth(event:Event, slot:Int, numSlots:Int, eventForSlot:[Int:Event]) -> CGFloat
	{
		var occupiedSlots:CGFloat = 1
		var nextSlot = slot + 1
		//while the next slot isn't filled and we haven't reached the rightmost slot
		while (canUseSlot(nextSlot, event: event, eventForSlot: eventForSlot) && nextSlot < numSlots)
		{
			occupiedSlots += 1
			nextSlot += 1
		}
		return fullCellWidth() / CGFloat(numSlots) * occupiedSlots
	}
	/**
		Returns true if the given event can be fitted into this slot. There are 3 ways this can happen:
		1. The slot is empty.
		2. The event in the slot ends before this event starts.
		3. The event in the slot starts after this event ends.
		
		- parameters:
			- slot: The slot we plan to put the event in.
			- event: The event we want to put in the slot.
			- eventForSlot: The events that are currently assigned to each slot.
		- returns: True if the event can use the slot.
	*/
	private func canUseSlot(_ slot:Int, event:Event, eventForSlot:[Int:Event]) -> Bool
	{
		return eventForSlot[slot] == nil || minutesBetween(event.endTime, and: eventForSlot[slot]!.startTime) >= 0 || minutesBetween(eventForSlot[slot]!.endTime, and: event.startTime) >= 0
	}
	/**
		Returns the maximum width an event can have. Also the default width for time lines.
		- returns: Max width for events and time lines.
	*/
	private func fullCellWidth() -> CGFloat
	{
		return scrollView.frame.width - CONTAINER_RIGHT_MARGIN
	}
	/**
		Returns how tall an event should be based on its length.
		- parameter event: The event to determine the height for.
		- returns: Height of the event.
	*/
	private func cellHeight(event:Event) -> CGFloat
	{
		//60 min = 1 rowHeight
		return CGFloat(minutesBetween(event.startTime, and: event.endTime)) / 60 * tableView.rowHeight
	}
	/**
		Returns the number of minutes between 2 given times. Note that this accounts for events that cross over midnight. An event that begins at 11PM and ends at 2AM lasts 3 hours, not -21.
		- parameters:
			- startTime: Start
			- endTime: End
		- returns: Number of minutes in between.
	*/
	private func minutesBetween(_ startTime:Time, and endTime:Time) -> Int
	{
		//check if we're crossing over the midnight mark. If we are, reverse the minutes
		if (endTime.hour < ScheduleVC.START_HOUR && startTime.hour >= ScheduleVC.START_HOUR)
		{
			return 24*60 - Time.length(startTime:endTime, endTime:startTime)
		}
		else if (startTime.hour < ScheduleVC.START_HOUR && endTime.hour >= ScheduleVC.START_HOUR)
		{
			return Time.length(startTime:endTime, endTime:startTime)
		}
		else
		{
			return Time.length(startTime:startTime, endTime:endTime)
		}
	}
	
    // MARK:- Event Actions
	
	/**
		Starts segue to `DetailsVC` when event is clicked.
		- parameter sender: Touch event that contains the view that was touched.
	*/
    @objc func eventClicked(_ sender: UITapGestureRecognizer)
	{
		guard let eventView = sender.view,
			let event = eventViews[eventView] else {
			print("Unknown object was clicked")
			return
		}
		selectedEvent = event
		performSegue(withIdentifier: "showDetailsVC", sender: self)
    }
    
    // MARK:- Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        return ScheduleVC.HOURS.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleCell
        cell.configure(title: ScheduleVC.HOURS[indexPath.row].hourDescription)
        return cell
    }
    
    //synchronize scrolling between table & scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView)
	{
        let viewToSyncScrolling = (scrollView == self.scrollView) ? tableView : self.scrollView
        viewToSyncScrolling?.contentOffset = scrollView.contentOffset
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
        if segue.identifier == "showDetailsVC"
		{
            if let destination = segue.destination as? DetailsVC
			{
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
    func setNotificationListener()
	{
		NotificationCenter.default.addObserver(self, selector: #selector(updateSchedule), name: .reloadData, object: nil)
    }
    /**
		Redraw the selected events.
	*/
    @objc func updateSchedule()
	{
        eventViews.keys.forEach({$0.removeFromSuperview()})
        eventViews.removeAll()
        drawAllEvents()
    }
    
}
