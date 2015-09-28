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
    
    var context: NSManagedObjectContext?
    
    
    // MARK: Button actions
    func menuItemSelected(menuItem: MenuItem) {
        
        self.menuItem = menuItem
        
        menuBarButton.image = UIImage(named: "menu.png")
        
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
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func puppiesTapped(sender: AnyObject) {
        delegate?.toggleRightPanel?()
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
            managedObjectContext: self.context!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc.delegate = self
        fetchedResultsController = frc
    }
    
    struct TableView {
        struct CellIdentifiers {
            static let ItemCell = "ItemCell"
        }
    }
    var categoryId:Int?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fetchResults(self.categoryId!, entityName: "Item", column: "categoryId")
        
        do {
            try fetchedResultsController!.performFetch()
            
            tableView.reloadData()
            
        }
        catch _ {
            
        }
    }
}

// MARK: Table View Data Source

extension ItemViewController: UITableViewDataSource {
    
    /*func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.menuItem.name
    }*/
    func getPhotoFor(itemId:Int) -> String? {
        
        let fetchRequest = NSFetchRequest(entityName: "Item_Photo")
        
        fetchRequest.predicate = NSPredicate(format: "%d == itemId", itemId)
        
        var photo:String?
        
        do {
            
            var res:Item_Photo?
            
            try res = self.context!.executeFetchRequest(fetchRequest).first as? Item_Photo
            
            photo = res?.photo
        }
        catch {
        }
        return photo
    }
    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.ItemCell, forIndexPath: indexPath) as! ItemCell
    
        
       /* var imageView = UIImageView(frame: CGRectMake(10, 10, cell.frame.width - 10, cell.frame.height - 10))
        //let image = UIImage(named: ImageNames[indexPath.row])
        imageView.image = cell.categoryImgSmall.image
        //cell.backgroundView = UIView()
        cell.backgroundView.addSubview(imageView)*/
        
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        cell.configureItem(item)
        
        var photoUrl = getPhotoFor(item.itemId)
        if photoUrl != nil {
            let URL_SITE = "http://rezmis3k.bget.ru/test3/catalog2/"
            let DIR_IMG_UPL = "img/upload/"
            let DIR_IMG_CAMP = "item/"
            let DENSITY = "1/"
            let ext = "_1.jpg"
            
            photoUrl = URL_SITE + DIR_IMG_UPL + DIR_IMG_CAMP + DENSITY + photoUrl! + ext
            
            if(photoUrl != nil) {
                Alamofire.request(.GET, photoUrl!).response { (request, response, data, error) in
                    NSLog(photoUrl!)
                    cell.categoryImgSmall.image = UIImage(data: data!, scale:1)
                }
            }
        }
        
        return cell
    }
    
}

// Mark: Table View Delegate

extension ItemViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        menuBarButton.image = UIImage(named: "back.png")
        
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        parentStack.push(item.categoryId)
        
        
    }
    
}

class ItemCell: UITableViewCell {
   
    @IBOutlet weak var categoryImgSmall: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
   
    func configureItem(item: Item) {
        //  animalImageView.image = animal.image
        categoryLabel.text = item.shortName
        
        //imageCreatorLabel.text = animal.creator
    }
    
}
