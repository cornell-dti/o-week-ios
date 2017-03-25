//
//  ScheduleVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/18/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class ScheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    // MARK:- Properties
    
    @IBOutlet var views: [UIView]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myScrollView: UIScrollView!
    
    var selected: Int = 0 //index of date selected (0-4)
    var hours = ["7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM", "12 AM", "1 AM", "2 AM"] //Table view data
    
    // MARK:- Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpNavBar()
        setUpExtendedNavBar()
        setUpGestureRecognizers()
        setUpTableView()
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
    
    func setUpTableView(){
        myTableView.allowsSelection = false
    }
    
    // MARK:- Date Actions
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        //TODO: implement filtering functionality for selected date
        switch sender.view {
        case views[0]?: changeSelectedDate(to: 0)
        case views[1]?: changeSelectedDate(to: 1)
        case views[2]?: changeSelectedDate(to: 2)
        case views[3]?: changeSelectedDate(to: 3)
        case views[4]?: changeSelectedDate(to: 4)
        default: break
        }
    }
    
    func changeSelectedDate(to selected: Int){
        for index in 0...views.count - 1 {
            if(index == selected){
                views[index].backgroundColor = UIColor.white
                labels[index].textColor = UIColor.black
            }else{
                views[index].backgroundColor = Color.RED
                labels[index].textColor = UIColor.white
            }
        }
    }
    
    //MARK:- Table View 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hours.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleCell
        cell.configure(title: hours[indexPath.section])
        return cell
    }
    
    //MARK:- Scroll View
    
    //FIXME: Not scrolling to bottom if scrolled via scrollview and not tableview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x != 0){
            scrollView.contentOffset.x = 0 //Remove horizontal scrolling
        }
        if (scrollView.contentOffset.y < 0){
            scrollView.contentOffset.y = 0
        }
        if (myTableView == scrollView) {
            myScrollView.setContentOffset(scrollView.contentOffset, animated: false)
        } else {
            myTableView.setContentOffset(scrollView.contentOffset, animated: false)
        }
    }
    
}
