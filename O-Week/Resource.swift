//
//  Resource.swift
//  O-Week
//
//  Created by Ethan Hu on 8/11/19.
//  Copyright © 2019 Cornell SA Tech. All rights reserved.
//

import Foundation

/**
 Datatype that holds resources in the settings page
 */
struct Resource {
    var link: String
    var name: String
    
    
    private init(link:String, name: String) {
        self.link = link
        self.name = name
    }
    
    
    /**
     Creates an resource object using data downloaded from the database.
     */
    init?(jsonOptional: [String:Any]?)
    {
        guard let json = jsonOptional,
            let name = json["name"] as? String,
            let link = json["link"] as? String
            else {
                print("Resources.jsonOptional: incorrect JSON format")
                return nil
        }
        self.link = link
        self.name = name
    }
    
    /**
     Convert this resource to a string to save to disk.
     - returns: String representation of this object.
     */
    func toString() -> String
    {
        return "\(name)|\(link)"
    }
    
    /**
     Creates an resource object from its string representation.
     - parameter str: String representation of an resource.
     - returns: resource object.
     */
    static func fromString(_ str: String) -> Resource
    {
        let parts = str.components(separatedBy: "|")
        let name = parts[0]
        let link = parts[1]
        
        return Resource(link: link, name: name)
    }
}
