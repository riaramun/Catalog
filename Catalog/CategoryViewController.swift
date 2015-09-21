//
//  CenterViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
    optional func animalSelected(animal: Category)
}


class CategoryViewController: UIViewController, NSFetchedResultsControllerDelegate, LeftPanelViewControllerDelegate {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var viewNavigationItem: UINavigationItem!
    var menuItem: MenuItem = MenuItem (type: .ECategories)
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: CenterViewControllerDelegate?
    
    var context: NSManagedObjectContext!
    
    
    // MARK: Button actions
    func menuItemSelected(menuItem: MenuItem) {
        self.menuItem = menuItem
        menuBarButton.image = UIImage(named: "menu.png")
        viewNavigationItem.title = menuItem.name
        moveMenuToLevel(0)
        delegate?.toggleLeftPanel?()
    }
    
    func moveMenuToLevel(parent:Int) {
        initfetchedResultsController(parent)
        do {
            try fetchedResultsController!.performFetch()
            tableView.reloadData()
            
        } catch _ {
        }
    }
    
    @IBAction func kittiesTapped(sender: AnyObject) {
        if currentCategoryID == 0 {
            delegate?.toggleLeftPanel?()
        } else {
            menuBarButton.image = UIImage(named: "menu.png")
            moveMenuToLevel(0)
        }
        
    }
    
    @IBAction func puppiesTapped(sender: AnyObject) {
        delegate?.toggleRightPanel?()
    }
    
    
    var fetchedResultsController: NSFetchedResultsController? = nil;
    var currentCategoryID : Int = 0
    
    func initfetchedResultsController(parentCategoryId:Int) {
        currentCategoryID = parentCategoryId
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "%d == parent", parentCategoryId)
        
        let primarySortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        fetchedResultsController = frc
    }
    
    struct TableView {
        struct CellIdentifiers {
            static let CategoryCell = "CategoryCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initfetchedResultsController(0)
        viewNavigationItem.title = menuItem.name
        do {
            try fetchedResultsController!.performFetch()
            tableView.reloadData()
            
        } catch _ {
        }
    }
}

// MARK: Table View Data Source

extension CategoryViewController: UITableViewDataSource {
    
    /*func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.menuItem.name
    }*/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController!.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController!.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.CategoryCell, forIndexPath: indexPath) as! CategoryCell
        let category = fetchedResultsController!.objectAtIndexPath(indexPath) as! Category
        
        cell.configureForCategory(category)
        // cell.textLabel?.text = animal.name
        //cell.detailTextLabel?.text = animal.habitat
        
        return cell
    }
    
}

// Mark: Table View Delegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let selectedAnimal = categories[indexPath.row]
        //delegate?.animalSelected(selectedAnimal)
        menuBarButton.image = UIImage(named: "back.png")
        
        // let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! CategoryCell;
        let fetchRequest = NSFetchRequest(entityName: "Category")
        //  let label:String = currentCell.categoryLabel.text!
        fetchRequest.predicate = NSPredicate(format: "%d == position", indexPath.row)
        var res:Category?
        var fetchResults : [Category]
        do {
            try fetchResults = self.context!.executeFetchRequest(fetchRequest) as! [Category]
            res = fetchResults[0]
            initfetchedResultsController(res!.category_id)
            viewNavigationItem.title = res!.name
            try fetchedResultsController!.performFetch()
            tableView.reloadData()
        }
        catch {
        }
    }
    
}

class CategoryCell: UITableViewCell {
    
    let URL_SITE = "http://rezmis3k.bget.ru/test3/catalog2/"
    let DIR_IMG_UPL = "img/upload/"
    let DIR_IMG_CAMP = "category/"
    let DENSITY = "1/"
    let ext = ".jpg"
    
    func getUrl(category: Category)->String {
        return URL_SITE + DIR_IMG_UPL + DIR_IMG_CAMP + DENSITY + category.photo + ext
    }
    
    @IBOutlet weak var categoryImgSmall: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    //@IBOutlet weak var animalImageView: UIImageView!
    // @IBOutlet weak var imageNameLabel: UILabel!
    //@IBOutlet weak var imageCreatorLabel: UILabel!
    
    func configureForCategory(category: Category) {
        //  animalImageView.image = animal.image
        categoryLabel.text = category.name
        
        let photoUrl = getUrl(category)
        Alamofire.request(.GET, photoUrl).response { (request, response, data, error) in
            NSLog(photoUrl)
            self.categoryImgSmall.image = UIImage(data: data!, scale:1)
        }
        //imageCreatorLabel.text = animal.creator
    }
    
}


extension CategoryViewController: SidePanelViewControllerDelegate {
    func animalSelected(category: Category) {
        // imageView.image = animal.image
        //  titleLabel.text = category.name
        // creatorLabel.text = animal.creator
        
        delegate?.collapseSidePanels?()
    }
}