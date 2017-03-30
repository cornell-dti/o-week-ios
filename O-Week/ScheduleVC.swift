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
    
    @IBOutlet var views: [UIView]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myScrollView: UIScrollView!
    var contentView: UIView!
    
    var selected = 0 //index of date selected (0-4)
    var hours = [Time(hour:7), Time(hour:8), Time(hour:9), Time(hour:10), Time(hour:11), Time(hour:12), Time(hour:13), Time(hour:14), Time(hour:15), Time(hour:16), Time(hour:17), Time(hour:18), Time(hour:19), Time(hour:20), Time(hour:21), Time(hour:22), Time(hour:23), Time(hour:0), Time(hour:1), Time(hour:2)] //Table view data
    
    let CONTAINER_RIGHT_MARGIN:CGFloat = 20
    
    // MARK:- Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpNavBar()
        setUpExtendedNavBar()
        setUpGestureRecognizers()
        setUpContentView()
        drawTimeLines()
        drawCells()
    }
    
    func setUpNavBar(){
        self.navigationItem.title = "My Schedule"
    }
    
    func setUpExtendedNavBar(){
        navigationController?.navigationBar.shadowImage = UIImage(named: "transparent_pixel")
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pixel"), for: .default)
        for view in views{
            view.layer.cornerRadius = view.frame.width / 2 //half of width for a perfect circle
        }
        changeSelectedDate(to: 0)
    }
    
    func setUpGestureRecognizers(){
        for view in views {
            let gr = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            view.addGestureRecognizer(gr)
            view.isUserInteractionEnabled = true
        }
    }
    
    func setUpContentView()
    {
        let frame = myScrollView.frame
        let newHeight = CGFloat(hours.count) * myTableView.rowHeight
        let newFrame = CGRect(x:0, y: 0, width: frame.width, height: newHeight)
        
        contentView = UIView(frame: newFrame)
        myScrollView.addSubview(contentView)
        myScrollView.contentSize = CGSize(width: frame.width, height: newHeight)
    }
    
    func drawTimeLines()
    {
        for hour in hours
        {
            let line = UIView(frame: CGRect(x: 0, y: yForStartTime(hour), width: cellWidth(), height: 0.5))
            line.backgroundColor = Color.GRAY
            contentView.addSubview(line)
        }
    }
    
    func drawCells()
    {
        //consider events that start earliest first
        let sortedEvents = FeedCell.selectedEvents.sorted(by: {$0.startTime < $1.startTime})
        
        for event in sortedEvents
        {
            let container = UIView(frame: CGRect(x: 0, y: yForStartTime(event.startTime), width: cellWidth(), height: cellHeight(event: event)))
            container.backgroundColor = Color.RED
            
            contentView.addSubview(container)
            
            let title = UILabel(frame: CGRect(x: 16, y: 14, width: 0, height: 0))
            title.numberOfLines = 0
            title.lineBreakMode = .byTruncatingTail
            title.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
            title.textColor = UIColor.white
            title.text = event.title
            title.sizeToFit()
            //bound right margin so title doesn't go past the block
            if (title.frame.width > container.frame.width - 32)
            {
                title.frame = CGRect(x: title.frame.origin.x, y: title.frame.origin.y, width: container.frame.width - 32, height: title.frame.height)
            }
            container.addSubview(title)
            
            let caption = UILabel(frame: CGRect(x: 16, y: title.frame.origin.y + title.frame.height, width: 0, height: 0))
            caption.numberOfLines = 0
            caption.lineBreakMode = .byTruncatingTail
            caption.font = UIFont(name: "AvenirNext-Regular", size: 10)
            caption.textColor = UIColor.white
            caption.text = event.caption
            caption.sizeToFit()
            //bound right margin so title doesn't go past the block
            if (caption.frame.width > container.frame.width - 32)
            {
                caption.frame = CGRect(x: caption.frame.origin.x, y: caption.frame.origin.y, width: container.frame.width - 32, height: caption.frame.height)
            }
            container.addSubview(caption)
        }
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
    
    func changeSelectedDate(to selected: Int)
    {
        //revert last selected date
        views[self.selected].backgroundColor = Color.RED
        labels[self.selected].textColor = UIColor.white
        //set new selected date
        views[selected].backgroundColor = UIColor.white
        labels[selected].textColor = UIColor.black
        
        self.selected = selected
    }
    
    //MARK:- Table View 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleCell
        cell.configure(title: hours[indexPath.row].hourDescription)
        return cell
    }
    
    //synchronize scrolling between table & scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let viewToSyncScrolling = (scrollView == myScrollView) ? myTableView : myScrollView
        viewToSyncScrolling?.contentOffset = scrollView.contentOffset
    }
    
    //MARK:- Private functions for drawing cells
    private func yForStartTime(_ startTime:Time) -> CGFloat
    {
        let timeFrom7 = Time.length(startTime: hours[0], endTime: startTime)
        return CGFloat(timeFrom7) * myTableView.rowHeight / 60 + (myTableView.rowHeight / 2)
    }
    private func cellWidth() -> CGFloat
    {
        return myScrollView.frame.width - CONTAINER_RIGHT_MARGIN
    }
    private func cellHeight(event:Event) -> CGFloat
    {
        //60 min = 1 rowHeight
        return CGFloat(Time.length(startTime: event.startTime, endTime: event.endTime)) / 60 * myTableView.rowHeight
    }
}
