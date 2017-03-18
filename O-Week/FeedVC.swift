//
//  FeedVC.swift
//  O-Week
//
//  Created by David Chu on 2017/3/17.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

class FeedVC:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    let data = [["7:45 AM", "8:45 AM", "Alumni Families and Legacy Reception", "Tent on Rawlings Green"],
                ["8:45 AM", "10:00 AM", "New Student Convocation", "Shoellkopf Stadium"],
                ["10:00 AM", "11:30 AM", "Tours of Libraries and Manuscript", "Upper Lobby, Uris Library"],
                ["10:00 AM", "6:00 PM", "Dump and Run Sale", "Helen Newman Hall"],
                ["10:30 AM", "11:30 AM", "AAP—Dean’s Convocation", "Abby and Howard Milstein Hall"],
                ["10:30 AM", "11:30 AM", "CALS—Dean’s Convocation", "Call Alumni Auditorium, Kennedy Hall"]]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage(named: "transparent_pixel")
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pixel"), for: .default)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        let dataForCell = data[indexPath.row]
        cell.configure(title: dataForCell[2], caption: dataForCell[3], startTime: dataForCell[0], endTime: dataForCell[1])
        return cell
    }
    
}
