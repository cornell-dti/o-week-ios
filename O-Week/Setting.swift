//
//  Setting.swift
//  O-Week
//
//  Created by Vicente Caycedo on 5/1/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import Foundation

class Setting {
    
    let name: String
    let allOptions: [String]
    //var chosenOption: String?
    
    init(name: String, allOptions: [String], chosenOption: String ){
        self.name = name
        self.allOptions = allOptions
        //self.chosenOption = chosenOption
    }
    
}
