//
//  Internet.swift
//  O-Week
//
//  Created by Yung Chang Chu on 2017/4/23.
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
    /**
     Enum containing all the URLs to be used for internet communication
     */
    private enum Urls:String
    {
        case regId = "http://nshsguide.newton.k12.ma.us/ajax/set-reg-id-ios.php"
        case feedback = "http://nshsguide.newton.k12.ma.us/feedback.php"
        case absentTeachers = "http://nshsguide.newton.k12.ma.us/ajax/absent-teachers.php"
        case announcement = "http://nshsguide.newton.k12.ma.us/ajax/get-announcement.php"
        case specialSchedule = "http://nshsguide.newton.k12.ma.us/ajax/special-schedule-list.php"
        case teachersList = "http://nshsguide.newton.k12.ma.us/ajax/get-faculty.php"
        case teacherRequest = "http://nshsguide.newton.k12.ma.us/ajax/set-teacher-request-ios.php"
    }
    /**
     Enum containing keys for additional information POST'ed to the database or received from the database
     */
    /*enum Keys:String
     {}*/
    
    //suppress default constructor for noninstantiability
    private init(){}
    
    /**
     Given a JSON dictionary outputted by the database, determines what to do with the information.
     - parameters:
     - jsonDictionary: JSON outputted by the server
     */
    static func parseJSON(_ json:Any)
    {
    }
    
    static func imageFrom(_ urlString:String, imageView:UIImageView)
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
    private static func post(url:Urls, keyValues:[(key:String, value:String)]?, completion:(() -> ())?)
    {
        let keyValuesString = keyValues == nil ? "" : keyValueToStringForPOST(keyValues!)
        
        var request = URLRequest(url: URL(string: url.rawValue)!)
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
