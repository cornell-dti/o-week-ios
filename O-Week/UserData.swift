//
//  UserData.swift
//  O-Week
//
//  Created by Vicente Caycedo on 4/28/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//
//  Holds user's added events

import Foundation
import CoreData

class UserData{
    
    static var allEvents: [Event] = []
    static var selectedEvents:Set<Event> = Set()
    
    /*
     Idea: on start up, download all event data and store w core data
     Only let user change added var
     
     //Deleting data
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     
     let noteEntity = "Note" //Entity Name
     
     let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     let note = notes[indexPath.row]
     if editingStyle == .delete {
     managedContext.delete(note)
     do {
     try managedContext.save()
     } catch let error as NSError {
     print("Error While Deleting Note: \(error.userInfo)")
     }
     }
     //Code to Fetch New Data From The DB and Reload Table.
     let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: noteEntity)
     do {
     notes = try managedContext.fetch(fetchRequest) as! [Note]
     } catch let error as NSError {
     print("Error While Fetching Data From DB: \(error.userInfo)")
     }
     noteTableView.reloadData()
     }
     
    */
}
