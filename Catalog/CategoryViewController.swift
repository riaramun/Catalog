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


class CategoryViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var viewNavigationItem: UINavigationItem!
    var menuItem: MenuItem = MenuItem (type: .ECategories)
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: CenterViewControllerDelegate?
    
    var context: NSManagedObjectContext!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ToItemView" {
            
            let viewController = segue.destinationViewController as! CollectionViewController
            
            /*let nav = segue.destinationViewController as! UINavigationController
            let viewController = nav.topViewController as! CollectionViewController*/
            
            viewController.context = self.context
            viewController.delegate = self.delegate
            let category = sender as! Category
            viewController.categoryId = category.categoryId
        }
        //viewController.viewNavigationItem.title = category.name
    }
    
    
    func performFetch() {
        do {
            try fetchedResultsController!.performFetch()
            tableView.reloadData()
        } catch _ {
        }
    }
    
    
    func getFirstCategoryParent() -> Int {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let category = fetchedResultsController!.objectAtIndexPath(indexPath) as! Category
        return category.parent
    }
    
    @IBAction func mainMenuBtnTapped(sender: AnyObject) {
        
        if fetchedResultsController?.fetchedObjects?.count > 0 && getFirstCategoryParent() == 0 {
            delegate?.toggleLeftPanel()
        } else {
            let parentOfParent = parentStack.size == 0 ? 0 : parentStack.pop()
            if parentOfParent != nil {
                fetchResults(parentOfParent!, entityName:"Category", column: "parent")
                performFetch()
                let parentId = getFirstCategoryParent();
                if parentId == 0 {
                    menuBarButton.image = UIImage(named: "menu.png")
                }
            }
        }
        
    }
    
    @IBAction func puppiesTapped(sender: AnyObject) {
        delegate?.toggleRightPanel()
    }
    
    var fetchedResultsController: NSFetchedResultsController? = nil
    
    var parentStack = Stack<Int>()
    
   
    
    func fetchResults(id:Int, entityName:String, column:String) {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%d == " + column, id)
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
        
        self.delegate!.setDrawerLeftPanel(true)
        
        fetchResults(0, entityName: "Category", column: "parent")
        viewNavigationItem.title = menuItem.name
        performFetch()
    }
}

extension CategoryViewController: LeftPanelViewControllerDelegate {

    // MARK: Button actions
    func menuItemSelected(menuItem: MenuItem) {
        
        self.menuItem = menuItem
        
        menuBarButton.image = UIImage(named: "menu.png")
        
        viewNavigationItem.title = menuItem.name
        
        delegate?.toggleLeftPanel()
        
        fetchResults(0, entityName:"Category", column: "parent")
        
        performFetch()
    }
}

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
        
        return cell
    }
    
}

// Mark: Table View Delegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let category = fetchedResultsController!.objectAtIndexPath(indexPath) as! Category
        
        menuBarButton.image = UIImage(named: "back.png")
        
        if category.categoryType == "item" {
            
            self.performSegueWithIdentifier("ToItemView", sender: category)
            
        } else {
            
            parentStack.push(category.parent)
            
            let fetchRequest = NSFetchRequest(entityName: "Category")
            
            fetchRequest.predicate = NSPredicate(format: "categoryId = %d",  category.categoryId )
            
            var res:Category?
            
            var results : [Category]
            
            do {
                
                try results = self.context!.executeFetchRequest(fetchRequest) as! [Category]
                
                res = results[0]
                
                fetchResults(res!.categoryId, entityName: "Category", column: "parent")
                
                viewNavigationItem.title = res!.name
                
                try fetchedResultsController!.performFetch()
                
                tableView.reloadData()
                
            }
                
            catch {
                
            }
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
