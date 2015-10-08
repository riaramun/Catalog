//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import CoreData
import DOCheckboxControl


protocol RightPanelViewControllerDelegate {
    func collapseFilterPanel()
    func getCurrentCategoryId() -> Int
}
protocol ColorsFilterDelegate {
    func setColors(colors:[String])
}
class RightPanelViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController? = nil
    var colorsFilter = [String]()
    var context: NSManagedObjectContext?
    var dataHelper: DataHelper?
    var delegate: RightPanelViewControllerDelegate?
    
    
    struct TableView {
        struct CellIdentifiers {
            static let FilterCell = "FilterCell"
        }
    }
    func performFetch() {
        do {
            try fetchedResultsController!.performFetch()
            tableView.reloadData()
        } catch _ {
        }
    }
    var properties:[Property]?
    
    func fetchResults() {
        
        properties = dataHelper?.fetchPropertiesByCategory((delegate?.getCurrentCategoryId())!)
        
        var reqStr = ""
        var counter = 0
        for property in properties! {
            reqStr += "propertyId == " + String(property.propertyId)
            if ++counter < properties?.count {
                reqStr += " or "
            }
            
        }
        
        let fetchRequest = NSFetchRequest(entityName: "FilterItem")
        //fetchRequest.predicate = NSPredicate(format: reqStr)
        
        
        /*var filterItems: [FilterItem]?
        
        do {
            try filterItems = self.context!.executeFetchRequest(fetchRequest) as? [FilterItem]
        }
        catch {
        }
        
        for item in filterItems! {
            print(item.property.name)
        }*/
        
        
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let secondarySortDescriptor = NSSortDescriptor(key: "param", ascending: true)
        
        fetchRequest.sortDescriptors = [primarySortDescriptor,secondarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context!,
            sectionNameKeyPath: "property.propertyId",
            cacheName: nil)
        frc.delegate = self
        fetchedResultsController = frc
    }
    
    @IBAction func applyFilter(sender: AnyObject) {
        self.view.endEditing(true)
        /*self.dataHelper?.filterItemsByPrice( Int(self.minPrice.text!)!, max: Int(self.maxPrice.text!)!, currentPrice: true)*/
        delegate?.collapseFilterPanel()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let filterItem = sender as! FilterItem
        
        if segue.identifier == "ToPropertyEditor" {
            
            let viewController = segue.destinationViewController as! PropertyEditorViewController
            viewController.propertyId = filterItem.property.propertyId
            viewController.context = self.context
            viewController.delegate = self
        }
        else if segue.identifier == "ToPriceEditor" {
            let viewController = segue.destinationViewController as! PriceEditorViewController
            viewController.propertyId = filterItem.property.propertyId
            viewController.context = self.context
            viewController.delegate = self
        }
    }
    
    
    @IBAction func resetFilter(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.dataHelper?.resetfilter()
        delegate?.collapseFilterPanel()
    }
    
    
    @IBAction func onBackTapped(sender: AnyObject) {
        self.view.endEditing(true)
        delegate?.collapseFilterPanel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataHelper = DataHelper(context: self.context!)
        
        
        fetchResults()
        performFetch()
        
    }
    
}
extension RightPanelViewController: UITableViewDataSource {
    
    /*func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.menuItem.name
    }*/
    
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return properties![section].name
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return (self.properties?.count)!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties![section].filterItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.FilterCell, forIndexPath: indexPath) as! FilterTableViewCell
        
        let filterItem = getFilterItemBy(indexPath)
        
        
        
       // let obj = fetchedResultsController!.objectAtIndexPath(indexPath);
        
       // let filterItem = fetchedResultsController!.objectAtIndexPath(indexPath) as! FilterItem
        
        cell.titleLabel.text = filterItem.param
        
        return cell
    }
    
    func getFilterItemBy(indexPath: NSIndexPath) -> FilterItem {
        
        let property = self.properties![indexPath.section]
        let filterItem = property.filterItems.allObjects[indexPath.row] as! FilterItem
        return filterItem
    }
    
}
extension RightPanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //let propertyListValue = fetchedResultsController!.objectAtIndexPath(indexPath) as! Property_Item_List
        //let property = dataHelper!.fetchPropertyBy(propertyListValue.propertyId)
        let filterItem = getFilterItemBy(indexPath)
        
        let name = filterItem.property.name
        if name.containsString("цена") || name.containsString("Цена")
        {
            self.performSegueWithIdentifier("ToPriceEditor", sender: filterItem)
        }
        else {
            self.performSegueWithIdentifier("ToPropertyEditor", sender: filterItem)
        }
        
    }
    
}
class FilterTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
}

extension RightPanelViewController: PriceEditorDelegate {
    func setPrice(values:[String]) {
        
    }
}
extension RightPanelViewController: ColorsFilterDelegate {
    
    
    func setColors(colors:[String]) {
        
        self.colorsFilter = colors
        var res: String = ""
        for color in colors {
            res += color
            res += String(", ")
        }
    }
}

