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
    let DATABASE = "https://oweek.herokuapp.com"
    
    //suppress default constructor for noninstantiability
    private init(){}
    
    /**
     Given a JSON dictionary outputted by the database, determines what to do with the information.
     - parameters:
     - jsonDictionary: JSON outputted by the server
     */
    private static func parseJSON(_ json:Any)
    {
    }
    
    static func getEventsOn(_ day:Date) -> [Event]?
    {
        //TODO unfinished methods
        //let date =
        //post(url: "\(DATABASE)/feed/", keyValues: <#T##[(key: String, value: String)]?#>, completion: <#T##(() -> ())?##(() -> ())?##() -> ()#>)
        return nil
    }
    static func getEventsOn(_ day:Date, category:String) -> [Event]?
    {
        return nil
    }
    static func getEventOn(_ day:Date, pk:Int) -> Event?
    {
        return nil
    }
    static func getImageFor(_ event:Event, imageView:UIImageView)
    {
        return
    }
    static func getCategories() -> [String]?
    {
        return nil
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
     Sends a POST request to the given URL with the given keys, running the completion function when it is done. Always use this function to communicate with the server.
     - parameters:
     - url: URL to send the POST request to
     - keyValues: The key values to send along with the POST request. These will be read by the server
     - completionFunction: The function that will be run when the POST request is done
     */
    private static func post(url:String, keyValues:[(key:String, value:String)]?, completion:(() -> ())?)
    {
        let keyValuesString = keyValues == nil ? "" : keyValueToStringForPOST(keyValues!)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = keyValuesString.data(using: .utf8)
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
                    print("unwrapping from JSON error")
                }
            }
            runAsyncFunction(completion)
            
        })
        task.resume()
    }
    /**
     Converts the given key values to a form recognizable by the server, in the following format: "key1=value1&key2=value2..."
     - parameter keyValues: The key values to convert
     - returns: A string in the server-readable key value format
     */
    private static func keyValueToStringForPOST(_ keyValues:[(key:String, value:String)]) -> String
    {
        let combinedKeyValues = keyValues.map({"\($0.key)=\($0.value)"})
        return combinedKeyValues.joined(separator: "&")
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
