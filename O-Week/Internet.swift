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
    static let DATABASE = "https://oweekapp.herokuapp.com/flow/"
    
    //suppress default constructor for noninstantiability
    private init(){}
    
    static func getEventsOn(_ day:Date)
    {
		let components = UserData.userCalendar.dateComponents([.day], from: day)
		get(url: "\(DATABASE)feed/\(components.day!)", handler:
		{
			json in
			
			print("Url: https://oweekapp.herokuapp.com/flow/feed/\(components.day!)")
			
			guard let events = json as? [[String:Any]] else {
				return
			}
			
			events.map({Event(json: $0)}).forEach({
				event in
				guard event != nil else {
					print("getEventsOn: Unexpected event format")
					return
				}
				UserData.saveEvent(event!)
			})
			
			//if the day we're loading is the selected date
			if (UserData.userCalendar.compare(day, to: UserData.selectedDate, toGranularity: .day) == .orderedSame)
			{
				runAsyncFunction(
				{
					() -> () in
					NotificationCenter.default.post(name: .reload, object: nil)
					NotificationCenter.default.post(name: .reloadDateData, object: nil)
				})
			}
		})
    }
    static func getEventsOn(_ day:Date, category:String)
    {
		
    }
    static func getEventWith(_ pk:Int)
    {
    }
    static func getImageFor(_ event:Event, imageView:UIImageView)
    {
		if let image = UserData.loadImageFor(event)
		{
			imageView.image = image
		}
		else
		{
			imageFrom("\(DATABASE)event/\(event.pk)/image", imageView: imageView, event: event)
		}
    }
    static func getCategories()
    {
        
    }
	private static func imageFrom(_ urlString:String, imageView:UIImageView, event:Event)
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
					UserData.saveImage(downloadedImage, event: event)
                }
            }
        })
        task.resume()
    }
    /**
     Sends a GET request to the given URL with the given keys, running the completion function when it is done. Always use this function to communicate with the server.
     - parameters:
     - url: URL to send the GET request to
     - handler: A function used to process the info returned from the database
     */
    private static func get(url:String, handler:((Any?) -> ())?)
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
                    handler?(info)
                    return
                }
                catch
                {
                    print("Internet: unwrapping from JSON error")
                }
            }
            handler?(nil)
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
