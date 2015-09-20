//
//  CenterViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import CoreData

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
    optional func animalSelected(animal: Category)
}


class CenterViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: CenterViewControllerDelegate?
    
    var context: NSManagedObjectContext!
    
    
    // MARK: Button actions
    
    @IBAction func kittiesTapped(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
    
    @IBAction func puppiesTapped(sender: AnyObject) {
        delegate?.toggleRightPanel?()
    }
    
    
    
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
            static let CategoryCell = "CategoryCell"
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

extension CenterViewController: UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.CategoryCell, forIndexPath: indexPath) as! CategoryCell
        let category = fetchedResultsController.objectAtIndexPath(indexPath) as! Category
        
        cell.configureForCategory(category)
      // cell.textLabel?.text = animal.name
        //cell.detailTextLabel?.text = animal.habitat
        
        return cell
    }
    
}

// Mark: Table View Delegate

extension CenterViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let selectedAnimal = categories[indexPath.row]
        //delegate?.animalSelected(selectedAnimal)
    }
    
}

class CategoryCell: UITableViewCell {
    
   @IBOutlet weak var categoryLabel: UILabel!
    //@IBOutlet weak var animalImageView: UIImageView!
   // @IBOutlet weak var imageNameLabel: UILabel!
    //@IBOutlet weak var imageCreatorLabel: UILabel!
    
    func configureForCategory(category: Category) {
        //  animalImageView.image = animal.image
          categoryLabel.text = category.name
        //imageCreatorLabel.text = animal.creator
    }
    
}


extension CenterViewController: SidePanelViewControllerDelegate {
    func animalSelected(category: Category) {
        // imageView.image = animal.image
      //  titleLabel.text = category.name
        // creatorLabel.text = animal.creator
        
        delegate?.collapseSidePanels?()
    }
}