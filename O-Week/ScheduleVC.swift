//
//  ScheduleVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/18/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class ScheduleVC: UIViewController {
    
    // MARK:- Properties
    
    @IBOutlet var views: [UIView]!
    @IBOutlet var labels: [UILabel]!
    
    var selected: Int = 0 //index of date selected (0-4)
    
    // MARK:- Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpNavBar()
        setUpExtendedNavBar()
        setUpGestureRecognizers()
    }
    
    func setUpNavBar(){
        self.navigationItem.title = "My Schedule"
    }
    
    func setUpExtendedNavBar(){
        navigationController?.navigationBar.shadowImage = UIImage(named: "transparent_pixel")
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pixel"), for: .default)
        for view in views{
            view.layer.cornerRadius = 18 //half of width for a perfect circle
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
}
