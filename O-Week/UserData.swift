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
    
    static var selectedEvents:Set<Event> = Set()
    
    //static var selectedEvents: Set<NSManagedObject> = Set()
    
    /*
     Idea: on start up, download all event data and store w core data
     Only let user change added var
     
     
    cell.textLabel?.text = person.value(forKeyPath: "name") as? String
    self.save(name: nameToSave)
    
     func save(name: String) {
     
     guard let appDelegate =
     UIApplication.shared.delegate as? AppDelegate else {
     return
     }
     
     // Do in init or view did load
     let managedContext =
     appDelegate.persistentContainer.viewContext
     let entity =
     NSEntityDescription.entity(forEntityName: "Person",
     in: managedContext)!
     
     
     // for every person
     let person = NSManagedObject(entity: entity,
     insertInto: managedContext)
     person.setValue(name, forKeyPath: "name")
     do {
        try managedContext.save()
        people.append(person)
     } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
     }
     }
 
     //Retrieving data
     guard let appDelegate =
     UIApplication.shared.delegate as? AppDelegate else {
     return
     }
     
     let managedContext =
     appDelegate.persistentContainer.viewContext
     
     //2
     let fetchRequest =
     NSFetchRequest<NSManagedObject>(entityName: "Person")
     
     //3
     do {
     people = try managedContext.fetch(fetchRequest)
     } catch let error as NSError {
     print("Could not fetch. \(error), \(error.userInfo)")
     }
     
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
    
    /*
     Links
     
     Adding core data setup to existing project:
     
     Using core data:
     https://www.raywenderlich.com/145809/getting-started-core-data-tutorial
 
     
     
    */
}
