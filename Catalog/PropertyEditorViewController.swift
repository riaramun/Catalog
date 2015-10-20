//
//  PropertyEditorViewController.swift
//  DOCheckboxControl
//
//  Created by Dmytro Ovcharenko on 22.07.15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import DOCheckboxControl
import CoreData


class PropertyEditorViewController: UIViewController, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController? = nil
    var context: NSManagedObjectContext?
    var dataHelper: DataHelper?
    var delegate: PropertyFilterDelegate?
    
    struct TableView {
        struct CellIdentifiers {
            static let PropertyCell = "PropertyCell"
        }
    }
    func performFetch() {
        do {
            try fetchedResultsController!.performFetch()
            tableView.reloadData()
        } catch _ {
        }
    }
    @IBAction func onBackTapped(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    var itemsDictanary = [String:Bool]()
    
    
    @IBAction func onCheckTapped(sender: AnyObject) {
        
        let listId =  (sender as! CheckboxControl).tag
        
        let propertyListValue = self.dataHelper?.fetchPropertyListValueBy(listId)
        
        let key = (propertyListValue?.value)!
        
        itemsDictanary[key] = (sender as! CheckboxControl).selected
        
    }
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        //MyViewController shoud be the name of your parent Class
        if viewController as? RightPanelViewController != nil {
            dataHelper!.clearParams(property!)
            
            var params = [String]()
            
            for key in itemsDictanary.keys {
                
                if itemsDictanary[key]?.boolValue == true {
                    
                    params.append(key)
                }
            }
            
            if params.count > 0 {
                dataHelper!.updateFilterItem(params, property:property!)
            } else {
                dataHelper!.setEmptyFilterItem(property!)
            }
            do {
                try self.context!.save()
            } catch {
                
            }
            delegate!.updateView()
        }
    }
    
    var propertyId: Int?
    var property: Property?
    
    func fetchResults() {
       //let propListVal =  dataHelper!.fetchPropertyListValuesBy(propertyId!)
        let fetchRequest = NSFetchRequest(entityName: "Property_List_Value")
        fetchRequest.predicate = NSPredicate(format: "propertyId == %d", propertyId! )
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        self.dataHelper = DataHelper(context: self.context!)
        property = dataHelper?.fetchPropertyBy(propertyId!)
        self.title = property?.name
        fetchResults()
        performFetch()
        
    }
}
extension PropertyEditorViewController: UITableViewDataSource {
    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.PropertyCell, forIndexPath: indexPath) as! CheckboxTableViewCell
        
        let propListVal = fetchedResultsController!.objectAtIndexPath(indexPath) as! Property_List_Value
        
        cell.titleLabel.text = propListVal.value
        cell.checkbox.tag = propListVal.listId
        cell.checkbox.selected = false
        for param in property!.filterItems {
            if (param as! FilterItem).param == propListVal.value {
                cell.checkbox.selected = true
                itemsDictanary[propListVal.value] = true
                break
            }
        }
        return cell
    }
    
    
}
extension PropertyEditorViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
}
class CheckboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkbox: CheckboxControl!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        checkbox.setHighlighted(highlighted, animated: animated)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        
        if bounds.contains(touch.locationInView(self)) {
            checkbox.setHighlighted(false, animated: true)
            checkbox.setSelected(!checkbox.selected, animated: true);
        }
    }
}
