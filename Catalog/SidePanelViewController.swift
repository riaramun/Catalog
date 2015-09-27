//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import CoreData

/*protocol SidePanelViewControllerDelegate {
    func categorySelected(animal: Category)
}*/

class SidePanelViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
  // var delegate: SidePanelViewControllerDelegate?
    
    var context: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let animalsFetchRequest = NSFetchRequest(entityName: "Category")
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        //  let secondarySortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
        animalsFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: animalsFetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    struct TableView {
        struct CellIdentifiers {
            static let AnimalCell = "AnimalCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
            
        } catch _ {
        }
    }
}

// MARK: Table View Data Source

extension SidePanelViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.AnimalCell, forIndexPath: indexPath)
        let animal = fetchedResultsController.objectAtIndexPath(indexPath) as! Category
        
        cell.textLabel?.text = animal.name
        //cell.detailTextLabel?.text = animal.habitat
        
        return cell
    }
    
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let selectedAnimal = categories[indexPath.row]
        //delegate?.animalSelected(selectedAnimal)
    }
    
}

class AnimalCell: UITableViewCell {
    
    @IBOutlet weak var animalImageView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var imageCreatorLabel: UILabel!
    
    func configureForAnimal(animal: Category) {
        //  animalImageView.image = animal.image
        imageNameLabel.text = animal.name
        //imageCreatorLabel.text = animal.creator
    }
    
}