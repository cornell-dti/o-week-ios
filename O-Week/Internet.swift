//
//  Internet.swift
//
//  Created by David Chu on 2017/4/23.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//
import UIKit
import SystemConfiguration

/**
 Handles ALL web-related activities for this app.
 - important: No over-the-web connections should be made outside of this class.
 */
class Internet
{
    //Link to the website where all event info is stored.
    static let DATABASE = "https://us-east1-oweek-1496849141291.cloudfunctions.net/"
    static let RESOURCE = "https://us-east1-oweek-1496849141291.cloudfunctions.net/getResources"
    
    //suppress default constructor for noninstantiability
    private init(){}
    
    /**
    
    Downloads all events and categories to update the app to the database's newest version. The `onCompletion` provided will be executed, provided with the new data as arguments. Then, classes that care about such updates will be updated
    
    - important: `onCompletion` will not be executed if the database does not contain a newer version. One should not depend on its execution.
    
    Expected JSON structure:
    
        {
             version: Int,
            categories:
            {
                changed: [Category.init(jsonOptional:[String:Any]), category2, ...],
                deleted: [Category.pk, pk2, ...]
            },
            events:
            {
                changed: [Event.init(jsonOptional:[String:Any])}, event2, ...],
                deleted: [Event.pk, pk2, ...]
            }
        }
    
    - Parameters:
        - version: Current version of database on file. Should be 0 if never downloaded from database.
        - finish: Function to execute when data is processed.
    */
    static func getUpdatesForVersion(_ version:Double, onCompletion finish:@escaping ((Double, [Category], [String], [Event], [String]) -> ()))
    {
        print("version: \(String(format: "%.0f", version))")
		get(url: "https://scraperjanorientationcornell.herokuapp.com/eventsiOS/", handler:
		{
			json in
			guard let data = json as? [String:Any],
					let newestVersion = data["timestamp"] as? Double,
                    let categories = data["categories"] as? [String:Any],
                    let changedCategoriesJSON = categories["changed"] as? [Any],
                    let deletedCategoriesPK = categories["deleted"] as? [String],
                    let events = data["events"] as? [String:Any],
                    let changedEventsJSON = events["changed"] as? [Any],
                    let deletedEventsPK = events["deleted"] as? [String],
                    //quick exit if version # did not change
                    version != newestVersion else {
                runAsyncFunction({NotificationCenter.default.post(name: .reloadData, object: nil)})
                return
            }
            
            
            //note: flatMap can also remove nils
            let changedCategories = changedCategoriesJSON.map({Category(jsonOptional: $0 as? [String:Any])}).compactMap({$0})
            let changedEvents = changedEventsJSON.map({Event(jsonOptional: $0 as? [String:Any])}).compactMap({$0})
            finish(newestVersion, changedCategories, deletedCategoriesPK, changedEvents, deletedEventsPK)

            //notify classes that need to know when events were updated
            runAsyncFunction({NotificationCenter.default.post(name: .reloadData, object: nil)})
        })
    }
    
    static func getResourceLinks(onCompletion finish:@escaping ([Resource]) -> ()) {
        get(url: RESOURCE, handler:
            {
                json in
                if let data = json as? [Any] {
                    let resources = data.map({Resource(jsonOptional: $0 as? [String:Any])}).compactMap({$0})
                    finish(resources)
                    runAsyncFunction({NotificationCenter.default.post(name: .reloadData, object: nil)})
                }
        })
    }
    
    /**
     Sends a GET request to the`url` with the given keys, retrieves a JSON object, then runs `handler` with the JSON object when it is done. Always use this function to communicate with the server.
     - Parameters:
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
     Runs `function` asynchronously. Use when attempting to modify UI from functions that involve internet connections. This is required because the UI thread must be independent from the internet threads in iOS, and not using this function will result in an exception.
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
