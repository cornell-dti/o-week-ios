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
    
    let data = [["8:45 AM", "10:00 AM", "New Student Convocation", "Shoellkopf Stadium"], ["8:45 AM", "10:00 AM", "New Student Convocation", "Shoellkopf Stadium"], ["8:45 AM", "10:00 AM", "New Student Convocation", "Shoellkopf Stadium"]]
    
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
