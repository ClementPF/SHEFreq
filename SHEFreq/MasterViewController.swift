//
//  MasterViewController.swift
//  SHEFreq
//
//  Created by clement perez on 12/28/16.
//  Copyright © 2016 clement perez. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class MasterViewController: UITableViewController , NSFetchedResultsControllerDelegate{

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var objects = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        restore()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        if(objects.count == 0){
            initList()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func restore(){
        
        let context = self.fetchedResultsController.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Environment")
        
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try context.fetch(fetchRequest)
            objects = results as! [Environment]
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func initList() {
        
        let context = self.fetchedResultsController.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Environment", in:context)
        let environment = NSManagedObject(entity: entity!, insertInto: context)
        
        environment.setValue("DTV remote server", forKey: kName)
        environment.setValue("http://192.168.1.1:8080/", forKey: kStbIP)
        environment.setValue("http://dev-freq-demo.freq.us:4007/", forKey: kServerIP)
        environment.setValue("apps/freq/minidock.html", forKey: kAppUrl)
        environment.setValue("a1:b2:c3:d4:e5", forKey: kMiniGenieAddr)
        environment.setValue(NSDate(), forKey: kDateCreated)
        
        let environment2 = NSManagedObject(entity: entity!, insertInto: context)
        
        environment2.setValue("DTV local server", forKey: kName)
        environment2.setValue("http://192.168.1.1:8080/", forKey: kStbIP)
        environment2.setValue("http://192.168.1.1:4005/", forKey: kServerIP)
        environment2.setValue("apps/freq/minidock.html", forKey: kAppUrl)
        environment.setValue("a1:b2:c3:d4:e5", forKey: kMiniGenieAddr)
        environment2.setValue(NSDate(), forKey: kDateCreated)
        
        do {
            try context.save()
            objects.append(environment as! Environment)
            objects.append(environment2 as! Environment)
            objects.sort(by: {($0 as! Environment).dateCreated!.timeIntervalSince1970 > ($1 as! Environment).dateCreated!.timeIntervalSince1970})
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    func insertNewObject(_ sender: Any) {
        
        let context = self.fetchedResultsController.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Environment", in:context)
        let environment = NSManagedObject(entity: entity!, insertInto: context)
        
        environment.setValue("New Configuration", forKey: kName)
        environment.setValue("http://192.168.1.1:8080/", forKey: kStbIP)
        environment.setValue("http://dev-freq-demo.freq.us:4007/", forKey: kServerIP)
        environment.setValue("apps/freq/minidock.html", forKey: kAppUrl)
        environment.setValue("a1:b2:c3:d4:e5", forKey: kAppUrl)
        environment.setValue(NSDate(), forKey: kDateCreated)
        
        do {
            try context.save()
            objects.append(environment as! Environment)
            objects.sort(by: {($0 as! Environment).dateCreated!.timeIntervalSince1970 > ($1 as! Environment).dateCreated!.timeIntervalSince1970})
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! Environment
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.environment = object
                controller.managedObjectContext = managedObjectContext
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = self.fetchedResultsController.object(at: indexPath)
        self.configureCell(cell, withEvent: event)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withEvent environment: Environment) {
        cell.textLabel!.text = environment.name!.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd hh:mm"
        let s = dateFormatter.string(from: environment.dateCreated as! Date)
        cell.detailTextLabel!.text = s
    }

    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Environment> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Environment> = Environment.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Environment>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Environment)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */

}

