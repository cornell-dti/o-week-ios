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
    var hours = ["7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", "12 AM", "1 AM", "2 AM"] //Table view data
    
    
    // MARK:- Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpNavBar()
        setUpExtendedNavBar()
        setUpGestureRecognizers()
        setUpContentView()
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
        let newFrame = CGRect(x:frame.origin.x, y: frame.origin.y, width: frame.width, height: newHeight)
        
        contentView = UIView(frame: newFrame)
        myScrollView.addSubview(contentView)
        myScrollView.contentSize = CGSize(width: frame.width, height: newHeight)
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
        cell.configure(title: hours[indexPath.row])
        return cell
    }
    
    //synchronize scrolling between table & scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let viewToSyncScrolling = (scrollView == myScrollView) ? myTableView : myScrollView
        viewToSyncScrolling?.contentOffset = scrollView.contentOffset
    }
    
}
