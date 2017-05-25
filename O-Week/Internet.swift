//
//  Internet.swift
//  O-Week
//
//  Created by David Chu on 2017/4/23.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//
//  Handles all communications with the database, sending and receiving information.
import UIKit
import SystemConfiguration

/**
 Handles all communications with the database, sending and receiving information.
 - important: No over-the-web connections should be made outside of this class
 */
class Internet
{
    static let DATABASE = "https://oweekapp.heroku.com/flow"
    
    //suppress default constructor for noninstantiability
    private init(){}
    
    /**
     Given a JSON dictionary outputted by the database, determines what to do with the information.
     - parameters:
     - jsonDictionary: JSON outputted by the server
     */
    private static func parseJSON(_ json:Any)
    {
        print(json)
    }
    
    static func getEventsOn(_ day:Date)
    {
        //TODO unfinished methods
        //let date =
        //post(url: "\(DATABASE)/feed/", keyValues: <#T##[(key: String, value: String)]?#>, completion: <#T##(() -> ())?##(() -> ())?##() -> ()#>)
    }
    static func getEventsOn(_ day:Date, category:String)
    {
    }
    static func getEventOn(_ day:Date, pk:Int)
    {
    }
    static func getImageFor(_ event:Event, imageView:UIImageView)
    {
    }
    static func getCategories()
    {
        get(url: "\(DATABASE)/event/3", completion: nil)
    }
    private static func imageFrom(_ urlString:String, imageView:UIImageView)
    {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler:
        {
            data, response, error in
            
            //only parse data if it exists
            if (data != nil && data!.count != 0)
            {
                if let downloadedImage = UIImage(data: data!)
                {
                    runAsyncFunction({imageView.image = downloadedImage})
                }
            }
        })
        task.resume()
    }
    /**
     Sends a GET request to the given URL with the given keys, running the completion function when it is done. Always use this function to communicate with the server.
     - parameters:
     - url: URL to send the GET request to
     - completionFunction: The function that will be run when the GET request is done
     */
    private static func get(url:String, completion:(() -> ())?)
    {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler:
        {
            data, response, error in
            
            //only parse data if it exists
            if (data != nil && data!.count != 0)
            {
                do
                {
                    let info = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    self.parseJSON(info)
                }
                catch
                {
                    print("Internet: unwrapping from JSON error")
                }
            }
            runAsyncFunction(completion)
            
        })
        task.resume()
    }
    /**
     Runs the given function asynchronously. Used because Internet communications should not be done on the UI-thread.
     - parameter function: Function to run
     */
    private static func runAsyncFunction(_ function:(() -> ())?)
    {
        if (function == nil) {
            return
        }
        DispatchQueue.main.async(execute: {
            function?()
        })
    }
}
