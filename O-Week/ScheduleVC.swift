//
//  ScheduleVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/18/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class ScheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    // MARK:- Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myScrollView: UIScrollView!
    var contentView: UIView!
    var containerViews = [UIView]()
    
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
    let TITLE_CAPTION_MARGIN:CGFloat = 16
    let CONTAINER_RIGHT_MARGIN:CGFloat = 20
    let EVENT_CORNER_RADIUS:CGFloat = 3
    let EVENT_BORDER_WIDTH: CGFloat = 1.25
	
    // MARK:- Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AppDelegate.setUpExtendedNavBar(navController: navigationController)
        setNotificationListener()
        
        datePickerController = DatePickerController(collectionView: collectionView)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        myScrollView.layoutIfNeeded()
        setUpContentView()
        drawTimeLines()
        drawCells()
    }
    
    func setUpContentView()
	{
        let frame = myScrollView.frame
        let newHeight = CGFloat(ScheduleVC.HOURS.count) * myTableView.rowHeight
        let newFrame = CGRect(x:0, y: 0, width: frame.width, height: newHeight)
        
        contentView = UIView(frame: newFrame)
        myScrollView.addSubview(contentView)
        myScrollView.contentSize = CGSize(width: frame.width, height: newHeight)
    }
    
    func drawTimeLines()
	{
        for hour in ScheduleVC.HOURS
        {
            let line = UIView(frame: CGRect(x: 0, y: yForStartTime(hour), width: fullCellWidth(), height: 0.5))
            line.backgroundColor = Constants.Colors.GRAY
            contentView.addSubview(line)
        }
    }
    
    func drawCells()
	{
        //consider events that start earliest first
        let sortedEvents = UserData.selectedEvents[UserData.selectedDate!]!.sorted(by: {$0.startTime < $1.startTime})
        guard !sortedEvents.isEmpty else {
            return
        }
        
        _ = drawContainer(parentSlot: 0, numSlots: 1, eventForSlot: [Int:Event](), events: sortedEvents)
    }
    
    func drawContainer(parentSlot:Int, numSlots:Int, eventForSlot:[Int:Event], events:[Event]) -> (numSlots:Int, eventForSlot:[Int:Event])
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
                let recursiveData = drawContainer(parentSlot: slot, numSlots: newNumSlots, eventForSlot: newEventForSlot, events: Array(events.dropFirst()))
                newNumSlots = recursiveData.numSlots
                newEventForSlot = recursiveData.eventForSlot
            }
            else {
                _ = drawContainer(parentSlot: slot, numSlots: 1, eventForSlot: [Int:Event](), events: Array(events.dropFirst()))
            }
        }
        
        let container = UIView(frame: CGRect(x: cellX(slot: slot, numSlots: newNumSlots), y: yForStartTime(event.startTime), width: cellWidth(event: event, slot: slot, numSlots: newNumSlots, eventForSlot: newEventForSlot), height: cellHeight(event: event)))
        container.backgroundColor = Constants.Colors.PINK
        container.layer.cornerRadius = EVENT_CORNER_RADIUS
        container.layer.borderColor = Constants.Colors.RED.cgColor
        container.layer.borderWidth = EVENT_BORDER_WIDTH
        contentView.addSubview(container)
        containerViews.append(container)
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
    
    func drawTitleAndCaptionFor(_ container:UIView, event:Event)
	{
        //First subview of "container" must be UILabel corresponding to Title for eventClicked func to work
        let title = UILabel()
        title.numberOfLines = 0
        title.lineBreakMode = .byTruncatingTail
        title.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        title.textColor = Constants.Colors.RED
        title.text = event.title
        title.translatesAutoresizingMaskIntoConstraints = false
        //title.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        //title.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)*/
        
        container.addSubview(title)
        
        let caption = UILabel()
        caption.numberOfLines = 0
        caption.lineBreakMode = .byTruncatingTail
        caption.font = UIFont(name: "AvenirNext-Regular", size: 10)
        caption.textColor = Constants.Colors.RED
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
    
    // MARK:- Event Actions
    
    func eventClicked(_ sender: UITapGestureRecognizer){
        //TODO: Clean up code
        //Subview[0] must be UILabel corresponding to Title
        //If above parameter is changed, update comment where UILabel is made and added to its parent view
        if let titleLabel = sender.view?.subviews[0] as! UILabel! {
            for setForDay in UserData.selectedEvents.values {
                for event in setForDay {
                    if event.title == titleLabel.text {
                        selectedEvent = event
                        performSegue(withIdentifier: "showDetailsVC", sender: self)
                    }
                }
            }
        } else {
            fatalError("Error with eventClicked function in ScheduleView")
        }
        
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
        let viewToSyncScrolling = (scrollView == myScrollView) ? myTableView : myScrollView
        viewToSyncScrolling?.contentOffset = scrollView.contentOffset
    }
    
    // MARK:- Private functions for drawing cells
    
    private func yForStartTime(_ startTime:Time) -> CGFloat
	{
		let timeFrom7 = minutesBetween(Time(hour: ScheduleVC.START_HOUR), and: startTime)
        return CGFloat(timeFrom7) * myTableView.rowHeight / 60 + (myTableView.rowHeight / 2)
    }
    
    private func cellX(slot:Int, numSlots:Int) -> CGFloat
	{
        return fullCellWidth() / CGFloat(numSlots) * CGFloat(slot)
    }
    
    //Returns the correct slot for this event
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
    
    //Returns true if any event on the eventForSlot list overlaps with the event of interest
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
    
    private func canUseSlot(_ slot:Int, event:Event, eventForSlot:[Int:Event]) -> Bool
	{
        return eventForSlot[slot] == nil || minutesBetween(event.endTime, and: eventForSlot[slot]!.startTime) >= 0 || minutesBetween(eventForSlot[slot]!.endTime, and: event.startTime) >= 0
    }
    
    private func fullCellWidth() -> CGFloat
	{
        return myScrollView.frame.width - CONTAINER_RIGHT_MARGIN
    }
    
    private func cellHeight(event:Event) -> CGFloat
	{
        //60 min = 1 rowHeight
        return CGFloat(minutesBetween(event.startTime, and: event.endTime)) / 60 * myTableView.rowHeight
    }
	
	//return minutes between 2 times, taking into account crossing over midnight.
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
    
    // MARK:- Navigation
    
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
    
    func setNotificationListener()
	{
        NotificationCenter.default.addObserver(self, selector: #selector(updateSchedule), name: .reloadData, object: nil)
    }
    
    func updateSchedule()
	{
        containerViews.forEach({$0.removeFromSuperview()})
        containerViews.removeAll()
        drawTimeLines()
        drawCells()
    }
    
}
