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
    func fetchResults() {
        
        let fetchRequest = NSFetchRequest(entityName: "Property_Item_List")
        fetchRequest.predicate = NSPredicate(format: "categoryId == %d", (delegate?.getCurrentCategoryId())!)
        
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
    
    @IBAction func applyFilter(sender: AnyObject) {
        self.view.endEditing(true)
        /*self.dataHelper?.filterItemsByPrice( Int(self.minPrice.text!)!, max: Int(self.maxPrice.text!)!, currentPrice: true)*/
        delegate?.collapseFilterPanel()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let propListVal = sender as! Property_Item_List
        let property = dataHelper!.fetchPropertyBy(propListVal.propertyId)
        
        if segue.identifier == "ToPropertyEditor" {
            
            let viewController = segue.destinationViewController as! PropertyEditorViewController
            viewController.propertyName = (property?.name)!
            viewController.context = self.context
            viewController.delegate = self
        }
        else if segue.identifier == "ToPriceEditor" {
            let viewController = segue.destinationViewController as! PriceEditorViewController
            viewController.propertyName = (property?.name)!
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.FilterCell, forIndexPath: indexPath) as! FilterTableViewCell
        
        let propListVal = fetchedResultsController!.objectAtIndexPath(indexPath) as! Property_Item_List
        let property = dataHelper!.fetchPropertyBy(propListVal.propertyId)
        cell.titleLabel.text = property?.name
        
        return cell
    }
    
}
extension RightPanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let propertyListValue = fetchedResultsController!.objectAtIndexPath(indexPath) as! Property_Item_List
        let property = dataHelper!.fetchPropertyBy(propertyListValue.propertyId)
        
        let name = property!.name
        if name.containsString("цена") || name.containsString("Цена")
        {
            self.performSegueWithIdentifier("ToPriceEditor", sender: propertyListValue)
        }
        else {
            self.performSegueWithIdentifier("ToPropertyEditor", sender: propertyListValue)
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

