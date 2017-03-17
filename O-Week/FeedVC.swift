//
//  FeedVC.swift
//  O-Week
//
//  Created by David Chu on 2017/3/17.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

class FeedVC:UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage(named: "transparent_pixel")
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pixel"), for: .default)
    }
}
