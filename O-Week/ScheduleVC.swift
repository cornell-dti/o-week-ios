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
    
    var selectedEvent: Event?
    var selectedDate: Date?
    var datePickerController: DatePickerController?
    
    let hours = [Time(hour:7), Time(hour:8), Time(hour:9), Time(hour:10), Time(hour:11), Time(hour:12), Time(hour:13), Time(hour:14), Time(hour:15), Time(hour:16), Time(hour:17), Time(hour:18), Time(hour:19), Time(hour:20), Time(hour:21), Time(hour:22), Time(hour:23), Time(hour:0), Time(hour:1), Time(hour:2)] //Table view data
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
        
        //Temporarily set date to first in UserData.dates array
        selectedDate = UserData.dates[0]
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        myScrollView.layoutIfNeeded()
        setUpContentView()
        drawTimeLines()
        drawCells()
    }
    
    func setUpContentView() {
        let frame = myScrollView.frame
        let newHeight = CGFloat(hours.count) * myTableView.rowHeight
        let newFrame = CGRect(x:0, y: 0, width: frame.width, height: newHeight)
        
        contentView = UIView(frame: newFrame)
        myScrollView.addSubview(contentView)
        myScrollView.contentSize = CGSize(width: frame.width, height: newHeight)
    }
    
    func drawTimeLines() {
        for hour in hours
        {
            let line = UIView(frame: CGRect(x: 0, y: yForStartTime(hour), width: fullCellWidth(), height: 0.5))
            line.backgroundColor = Color.GRAY
            contentView.addSubview(line)
        }
    }
    
    func drawCells() {
        //consider events that start earliest first
        let sortedEvents = UserData.selectedEvents[selectedDate!]!.sorted(by: {$0.startTime < $1.startTime})
        guard !sortedEvents.isEmpty else {
            return
        }
        
        _ = drawContainer(parentSlot: 0, numSlots: 1, eventForSlot: [Int:Event](), events: sortedEvents)
    }
    
    func drawContainer(parentSlot:Int, numSlots:Int, eventForSlot:[Int:Event], events:[Event]) -> (numSlots:Int, eventForSlot:[Int:Event]) {
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
        container.backgroundColor = Color.PINK
        container.layer.cornerRadius = EVENT_CORNER_RADIUS
        container.layer.borderColor = Color.RED.cgColor
        container.layer.borderWidth = EVENT_BORDER_WIDTH
        contentView.addSubview(container)
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
    
    func drawTitleAndCaptionFor(_ container:UIView, event:Event) {
        //First subview of "container" must be UILabel corresponding to Title for eventClicked func to work
        let title = UILabel()
        title.numberOfLines = 0
        title.lineBreakMode = .byTruncatingTail
        title.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        title.textColor = Color.RED
        title.text = event.title
        title.translatesAutoresizingMaskIntoConstraints = false
        //title.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        //title.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)*/
        
        container.addSubview(title)
        
        let caption = UILabel()
        caption.numberOfLines = 0
        caption.lineBreakMode = .byTruncatingTail
        caption.font = UIFont(name: "AvenirNext-Regular", size: 10)
        caption.textColor = Color.RED
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleCell
        cell.configure(title: hours[indexPath.row].hourDescription)
        return cell
    }
    
    //synchronize scrolling between table & scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewToSyncScrolling = (scrollView == myScrollView) ? myTableView : myScrollView
        viewToSyncScrolling?.contentOffset = scrollView.contentOffset
    }
    
    // MARK:- Private functions for drawing cells
    
    private func yForStartTime(_ startTime:Time) -> CGFloat {
        //TODO: Special treatment past midnight
        let timeFrom7 = Time.length(startTime: hours[0], endTime: startTime)
        return CGFloat(timeFrom7) * myTableView.rowHeight / 60 + (myTableView.rowHeight / 2)
    }
    
    private func cellX(slot:Int, numSlots:Int) -> CGFloat {
        return fullCellWidth() / CGFloat(numSlots) * CGFloat(slot)
    }
    
    //Returns the correct slot for this event
    private func slotForEvent(_ event:Event, numSlots:Int, eventForSlot:[Int:Event]) -> Int {
        for i in 0..<numSlots {
            if (canUseSlot(i, event: event, eventForSlot: eventForSlot)) {
                return i
            }
        }
        return numSlots
    }
    
    //Returns true if any event on the eventForSlot list overlaps with the event of interest
    private func areEventOverlaps(_ event:Event, numSlots:Int, eventForSlot:[Int:Event]) -> Bool {
        for i in 0..<numSlots
        {
            if (!canUseSlot(i, event: event, eventForSlot: eventForSlot))
            {
                return true
            }
        }
        return false
    }
    
    private func cellWidth(event:Event, slot:Int, numSlots:Int, eventForSlot:[Int:Event]) -> CGFloat {
        var occupiedSlots:CGFloat = 1
        var nextSlot = slot + 1
        //while the next slot isn't filled and we haven't reached the rightmost slot
        while (canUseSlot(nextSlot, event: event, eventForSlot: eventForSlot) && nextSlot < numSlots) {
            occupiedSlots += 1
            nextSlot += 1
        }
        return fullCellWidth() / CGFloat(numSlots) * occupiedSlots
    }
    
    private func canUseSlot(_ slot:Int, event:Event, eventForSlot:[Int:Event]) -> Bool {
        return eventForSlot[slot] == nil || eventForSlot[slot]!.startTime >= event.endTime || eventForSlot[slot]!.endTime <= event.startTime
    }
    
    private func fullCellWidth() -> CGFloat {
        return myScrollView.frame.width - CONTAINER_RIGHT_MARGIN
    }
    
    private func cellHeight(event:Event) -> CGFloat {
        //60 min = 1 rowHeight
        return CGFloat(Time.length(startTime: event.startTime, endTime: event.endTime)) / 60 * myTableView.rowHeight
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsVC" {
            if let destination = segue.destination as? DetailsVC {
                destination.event = selectedEvent
            }
        }
    }
    
    // MARK:- Handle Updates
    
    func setNotificationListener(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateSchedule), name: .reload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDate), name: .reloadDateData, object: nil)
    }
    
    func updateSchedule(){
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        myScrollView.layoutIfNeeded()
        setUpContentView()
        drawTimeLines()
        drawCells()
    }
    
    func updateDate(){
        selectedDate = datePickerController!.selectedCell!.date!
        updateSchedule()
    }
    
}
