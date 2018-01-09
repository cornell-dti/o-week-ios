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

	`contentView`: Holds all events and time lines. Direct child of `scrollView`. `UIScrollView`s should only have one child (its content), so this acts as a container for all events.
	`eventViews`: Holds a reference to each event view, so they can be destroyed on redraw. Each event view has its value as the corresponding event so the event can be passed to `DetailsVC` on click. Time lines are not redrawn so no reference to them is skept.
	`HOURS`: List of hours to display. Should be the full range of start/end times for events. Hours range: [START_HOUR, END_HOUR], inclusive. Hours wrap around, from 7~23, then 0~2.
	`START_HOUR`: The earliest hour an event can start.
	`END_HOUR`: The latest hour an event can end. Note that this is in AM; END_HOUR must < START_HOUR.
	`didLayout`: True if layout of subviews was completed. Used to ensure layout initialization is only done once.
*/
class ScheduleVC: UIViewController, DateContainer
{
    let scrollView = UIScrollView.newAutoLayout()
    let contentView = UIView.newAutoLayout()
	var eventViews = [UIView:Event]()
	
	private(set) var date:Date!
	var detailsVC:DetailsVC!
    
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
	//a time line's distance from the left. Change (somehow) once hour has dynamic width.
	//14 (hour's left margin) + 40 (hour's width) + 18 (hour's right margin) = 72
	let LEFT_MARGIN:CGFloat = 72
	
	var didLayout = false
	
    // MARK:- Setup
	
	/**
		Initialize to the given date.
		- parameters:
			- date: Date this `ScheduleVC` will show events for.
			- detailsVC: Reference to DetailsVC to segue to.
	*/
	convenience init(date:Date, detailsVC:DetailsVC)
	{
		self.init(nibName: nil, bundle: nil)
		self.date = date
		self.detailsVC = detailsVC
	}
	/**
		Start listening for changes in events.
	*/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setNotificationListener()
    }
    /**
		Set up the scroll view and draw time lines and events.
	*/
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
		
		guard !didLayout else {
			scrollToNow()
			return
		}
		didLayout = true
		
        setUpScrollView()
		scrollView.layoutIfNeeded()
        drawTimeLines()
        drawAllEvents()
		scrollToNow()
    }
    /**
		Sets up `scrollView` and `contentView`, which is the primary child view of `scrollView`.
	*/
    private func setUpScrollView()
	{
		view.addSubview(scrollView)
		scrollView.autoPinEdgesToSuperviewEdges()
		DatePageVC.makeSpaceForDatePicker(in: scrollView)
		
        let newHeight = CGFloat(ScheduleVC.HOURS.count) * Layout.HOUR_HEIGHT
        let newSize = CGSize(width: view.frame.width, height: newHeight)
        
        contentView.autoSetDimensions(to: newSize)
        scrollView.addSubview(contentView)
		contentView.autoPinEdgesToSuperviewEdges()
        scrollView.contentSize = newSize
    }
	/**
		Positions the scroll view to show the current hour. Does nothing if the current hour is out of range or if the displayed day isn't today.
	*/
	private func scrollToNow()
	{
		let today = Date()
		guard UserData.userCalendar.compare(today, to: date, toGranularity: .day) == .orderedSame else {
			return
		}
		
		let now = Time()
		guard minutesBetween(ScheduleVC.HOURS.first!, and: now) >= 0 && minutesBetween(now, and: ScheduleVC.HOURS.last!) >= 0 else {
			return
		}
		
		scrollView.contentOffset = CGPoint(x: 0, y: yForStartTime(now) - Layout.DATE_SIZE)
	}
    /**
		Draw all the time lines, one line for each hour in `HOURS`.
	*/
    private func drawTimeLines()
	{
        for hour in ScheduleVC.HOURS
        {
			let hourText = UILabel.newAutoLayout()
			let line = UIView.newAutoLayout()
			contentView.addSubview(hourText)
			contentView.addSubview(line)
			
			hourText.textAlignment = .right
			hourText.font = UIFont(name: Font.REGULAR, size: 12)
			hourText.text = hour.hourDescription
			hourText.alpha = 0.5
            line.backgroundColor = Colors.GRAY
			
			// TODO: find a way not to hard-code this
			hourText.autoSetDimension(.width, toSize: 40)
			hourText.autoPinEdge(toSuperviewEdge: .left, withInset: 14)
			line.autoPinEdge(.left, to: .right, of: hourText, withOffset: 18)
			line.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
			line.autoSetDimension(.height, toSize: 0.5)
			line.autoPinEdge(toSuperviewEdge: .top, withInset: yForStartTime(hour))
			hourText.autoAlignAxis(.horizontal, toSameAxisOf: line)
        }
    }
    /**
		Draws all selected events in order.
	*/
    private func drawAllEvents()
	{
        //consider events that start earliest first
        let sortedEvents = UserData.selectedEvents[date]!.sorted(by: {$0.startTime < $1.startTime})
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
		
		//events that aren't occurring right now will be faded out
		container.alpha = eventOngoing(event) ? 1 : 0.6
		
		container.backgroundColor = Colors.BRIGHT_RED
        container.layer.cornerRadius = 3
        container.layer.borderColor = Colors.BRIGHT_RED.withAlphaComponent(0.6).cgColor
        container.layer.borderWidth = 2
		container.layer.masksToBounds = true
		
        contentView.addSubview(container)
        eventViews[container] = event
        drawEvent(event, container: container)
        //add gesture recognizer to container to segue to Details VC
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.eventClicked(_:))))
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
		Draws event title, caption, time, and RQ, setting up margins within the given container.
		- parameters:
			- container: View that the event is displayed as.
			- event: Event whose info is displayed.
	*/
    func drawEvent(_ event:Event, container:UIView)
	{
		let REQUIRED_LABEL_SIZE:CGFloat = 24
		let MARGIN:CGFloat = 10
		let required = UserData.requiredForUser(event: event)
		
		var requiredLabel:UITextField?
		if (required)
		{
			requiredLabel = UITextField.newAutoLayout()
			requiredLabel?.autoSetDimensions(to: CGSize(width: REQUIRED_LABEL_SIZE, height: REQUIRED_LABEL_SIZE))
			requiredLabel?.isUserInteractionEnabled = false
			requiredLabel?.backgroundColor = UIColor.white
			requiredLabel?.textAlignment = .center
			requiredLabel?.textColor = Colors.RED
			requiredLabel?.text = "RQ"
			requiredLabel?.font = UIFont(name: Font.DEMIBOLD, size: 10)
			requiredLabel?.layer.cornerRadius = REQUIRED_LABEL_SIZE / 2
			
			container.addSubview(requiredLabel!)
			requiredLabel?.autoPinEdge(toSuperviewEdge: .right, withInset: MARGIN)
			requiredLabel?.autoPinEdge(toSuperviewEdge: .top, withInset: MARGIN)
		}
		
		let title = UILabel.newAutoLayout()
		title.numberOfLines = 0
		title.lineBreakMode = .byTruncatingTail
		title.font = UIFont(name: Font.DEMIBOLD, size: 14)
		title.textColor = UIColor.white
		title.text = event.title
		
		let textWidth = container.frame.width - MARGIN * 2 - (required ? (REQUIRED_LABEL_SIZE + MARGIN) : 0)
		let textHeight = container.frame.height - MARGIN * 2
		let singleLineHeight = title.heightForSingleLine(textWidth: textWidth)
		let numLinesUsed = title.visibleNumberOfLines(textWidth: textWidth)
		let numLinesAvailable = Int(textHeight / singleLineHeight)
		let numLinesRemaining = numLinesAvailable - numLinesUsed
		
		if (numLinesRemaining <= 0)
		{
			//only have room to show title
			title.numberOfLines = numLinesAvailable
			
			//add margin for required label as necessary
			let rightMargin = MARGIN + (required ? REQUIRED_LABEL_SIZE : 0)
			container.addSubview(title)
			title.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: MARGIN, left: MARGIN, bottom: MARGIN, right: rightMargin))
		}
		else
		{
			let paddedContainer = UIStackView.newAutoLayout()
			container.addSubview(paddedContainer)
			//don't pin bottom edge, otherwise the views will be stretched vertically to fill the entire container
			paddedContainer.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: MARGIN, left: MARGIN, bottom: MARGIN, right: MARGIN), excludingEdge: .bottom)
			paddedContainer.alignment = .top
			paddedContainer.axis = .vertical
			
			let caption = UILabel.newAutoLayout()
			caption.numberOfLines = 0
			caption.lineBreakMode = .byTruncatingTail
			caption.font = UIFont(name: Font.REGULAR, size: 12)
			caption.textColor = UIColor.white
			caption.text = event.caption
			
			if (numLinesRemaining == 1)
			{
				//only have 1 line left to show caption
				caption.numberOfLines = 1
				
				paddedContainer.addArrangedSubview(title)
				paddedContainer.addArrangedSubview(caption)
				
				//add required label margin as necessary
				if (required)
				{
					title.autoPinEdge(toSuperviewEdge: .right, withInset: REQUIRED_LABEL_SIZE)
				}
			}
			else
			{
				//multiple lines remaining
				caption.numberOfLines = numLinesRemaining - 1
				
				let time = UILabel.newAutoLayout()
				time.numberOfLines = 1
				time.lineBreakMode = .byTruncatingTail
				time.font = UIFont(name: Font.MEDIUM, size: 14)
				time.textColor = UIColor.white
				time.text = "\(event.startTime) - \(event.endTime)"
				
				paddedContainer.addArrangedSubview(time)
				paddedContainer.addArrangedSubview(title)
				paddedContainer.addArrangedSubview(caption)
				
				//add required label margin as necessary
				if (required)
				{
					time.autoPinEdge(toSuperviewEdge: .right, withInset: REQUIRED_LABEL_SIZE)
				}
			}
		}
    }
	/**
		Distance from the top for a given view based on its start time. The view should either be an event view or a time line.
		- parameter startTime: The start time of the event view or time line.
		- returns: Y position.
	*/
	private func yForStartTime(_ startTime:Time) -> CGFloat
	{
		let timeFrom7 = minutesBetween(Time(hour: ScheduleVC.START_HOUR), and: startTime)
		return CGFloat(timeFrom7) * Layout.HOUR_HEIGHT / 60 + (Layout.HOUR_HEIGHT / 2)
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
		return LEFT_MARGIN + fullCellWidth() / CGFloat(numSlots) * CGFloat(slot)
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
		return scrollView.frame.width - Layout.MARGIN - LEFT_MARGIN
	}
	/**
		Returns how tall an event should be based on its length.
		- parameter event: The event to determine the height for.
		- returns: Height of the event.
	*/
	private func cellHeight(event:Event) -> CGFloat
	{
		//60 min = 1 HOUR_HEIGHT
		return CGFloat(minutesBetween(event.startTime, and: event.endTime)) / 60 * Layout.HOUR_HEIGHT
	}
	/**
		Returns true if the given event is currently occurring.
		- parameter event: Event.
		- returns: Whether the given event is happening right now.
	*/
	private func eventOngoing(_ event:Event) -> Bool
	{
		let today = Date()
		guard UserData.userCalendar.compare(today, to: date, toGranularity: .day) == .orderedSame else {
			return false
		}
		
		let now = Time()
		let eventIsOngoing = minutesBetween(event.startTime, and: now) >= 0 && minutesBetween(now, and: event.endTime) >= 0
		return eventIsOngoing
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
		
		detailsVC.configure(event: event)
		navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    // MARK:- Handle Updates
	/**
		Begin listening for events that will change what needs to be displayed. Specifically:
		1. Whether an event is selected (can be changed by `DetailsVC`))
		2. Content of events we're showing (can be changed by updates from `Internet`)
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
