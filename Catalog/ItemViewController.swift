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


class ItemViewController: UIViewController, NSFetchedResultsControllerDelegate, LeftPanelViewControllerDelegate {
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
        
        delegate?.toggleLeftPanel?()
        
        fetchResults(0, entityName:"Item", column: "parent")
        
        performFetch()
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
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        return item.categoryId
    }
    
    @IBAction func mainMenuBtnTapped(sender: AnyObject) {
        
        if fetchedResultsController?.fetchedObjects?.count > 0 && getFirstCategoryParent() == 0 {
            delegate?.toggleLeftPanel?()
        } else {
            let parentOfParent = parentStack.size == 0 ? 0 : parentStack.pop()
            fetchResults(parentOfParent!, entityName:"Item", column: "parent")
            performFetch()
            let parentId = getFirstCategoryParent();
            if parentId == 0 {
                menuBarButton.image = UIImage(named: "menu.png")
            }
        }
        
    }
    
    @IBAction func puppiesTapped(sender: AnyObject) {
        delegate?.toggleRightPanel?()
    }
    
    var fetchedResultsController: NSFetchedResultsController? = nil
    
    var parentStack = Stack<Int>()
    
    
    /*func getParentOfParent() -> Int? {
    
    var retId:Int?
    let parentId = getFirstCategoryParent();
    
    let fetchRequest = NSFetchRequest(entityName: "Item")
    fetchRequest.predicate = NSPredicate(format: "%d == categoryId", parentId)
    
    var results:[Item]
    do{
    try results = self.context.executeFetchRequest(fetchRequest) as! [Item]
    if(results.count != 0) {
    let someCategory = results[0]
    retId = someCategory.parent
    }
    }
    catch {
    }
    return retId
    }*/
    
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
        
        fetchResults(0, entityName: "Item", column: "parent")
        
        viewNavigationItem.title = menuItem.name
        do {
            try fetchedResultsController!.performFetch()
            tableView.reloadData()
            
        } catch _ {
        }
    }
}

// MARK: Table View Data Source

extension ItemViewController: UITableViewDataSource {
    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.CategoryCell, forIndexPath: indexPath) as! ItemCell
        
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        cell.configureForCategory(item)
        
        return cell
    }
    
}

// Mark: Table View Delegate

extension ItemViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        menuBarButton.image = UIImage(named: "back.png")
        
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        parentStack.push(item.categoryId)
        
        let fetchRequest = NSFetchRequest(entityName: "Item")
        
        fetchRequest.predicate = NSPredicate(format: "name ='" + item.shortName + "'")
        
        var res:Item?
        
        var results : [Item]
        
        do {
            
            try results = self.context!.executeFetchRequest(fetchRequest) as! [Item]
            
            res = results[0]
            
            fetchResults(res!.categoryId, entityName: "Item", column: "parent")
            
            viewNavigationItem.title = res!.shortName
            
            try fetchedResultsController!.performFetch()
            
            tableView.reloadData()
            
        }
            
        catch {
            
        }
    }
    
}

class ItemCell: UITableViewCell {
    
    let URL_SITE = "http://rezmis3k.bget.ru/test3/catalog2/"
    let DIR_IMG_UPL = "img/upload/"
    let DIR_IMG_CAMP = "item/"
    let DENSITY = "1/"
    let ext = ".jpg"
    
    func getUrl(item: Item)->String {
        return ""//URL_SITE + DIR_IMG_UPL + DIR_IMG_CAMP + DENSITY + item.photo + ext
    }
    
    @IBOutlet weak var categoryImgSmall: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    //@IBOutlet weak var animalImageView: UIImageView!
    // @IBOutlet weak var imageNameLabel: UILabel!
    //@IBOutlet weak var imageCreatorLabel: UILabel!
    
    func configureForCategory(item: Item) {
        //  animalImageView.image = animal.image
        categoryLabel.text = item.shortName
        
        let photoUrl = getUrl(item)
        Alamofire.request(.GET, photoUrl).response { (request, response, data, error) in
            NSLog(photoUrl)
            self.categoryImgSmall.image = UIImage(data: data!, scale:1)
        }
        //imageCreatorLabel.text = animal.creator
    }
    
}

/*extension ItemViewController: SidePanelViewControllerDelegate {
    func itemSelected(item: Item) {
        // imageView.image = animal.image
        //  titleLabel.text = item.name
        // creatorLabel.text = animal.creator
        
        delegate?.collapseSidePanels?()
    }
}*/