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
	
	static func getUpdatesForVersion(_ version:Int, onCompletion finish:@escaping (() -> ()))
	{
		get(url: "\(DATABASE)version/\(version)", handler:
		{
			json in
			
			guard let data = json as? [String:Any],
					let newestVersion = data["version"] as? Int,
					let categories = data["categories"] as? [String:Any],
					let changedCategories = categories["changed"] as? [Any],
					let deletedCategories = categories["deleted"] as? [Int],
					let events = data["events"] as? [String:Any],
					let changedEvents = events["changed"] as? [Any],
					let deletedEvents = events["deleted"] as? [Int] else {
				return
			}
			
			//note: flatMap can also remove nils
			//update categories
			changedCategories.map({Category(jsonOptional: $0 as? [String:Any])})
				.flatMap({$0})
				.forEach({UserData.updateCategory($0)})
			//remove categories
			var newCategories = [Category]()
			for category in UserData.categories
			{
				if (deletedCategories.contains(category.pk))
				{
					UserData.removeFromCoreData(category)
				}
				else
				{
					newCategories.append(category)
				}
			}
			UserData.categories = newCategories
			
			//keep track of all changed events to notify the user
			var changedEventsTitles = [String]()
			//update events
			changedEvents.map({Event(jsonOptional: $0 as? [String:Any])})
				.flatMap({$0})
				.forEach({
					event in
					changedEventsTitles.append(event.title)
					UserData.updateEvent(event)
				})
			//delete events
			for date in UserData.dates
			{
				var newEventsForDate = [Event]()
				for event in UserData.allEvents[date]!
				{
					if (deletedEvents.contains(event.pk))
					{
						changedEventsTitles.append(event.title)
						UserData.removeFromCoreData(event)
					}
					else
					{
						newEventsForDate.append(event)
					}
				}
				UserData.allEvents[date] = newEventsForDate
				UserData.selectedEvents[date] = UserData.selectedEvents[date]!.filter({!deletedEvents.contains($0.pk)})
			}
			
			UserData.version = newestVersion
			finish()
			
			runAsyncFunction({NotificationCenter.default.post(name: .reloadData, object: nil)})
			print(changedEventsTitles)
			LocalNotifications.addNotification(for: changedEventsTitles)
		})
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
