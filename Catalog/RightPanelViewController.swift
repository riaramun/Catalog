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
    func updateView()
    func collapseFilterPanel()
    func getCurrentCategoryId() -> Int
}
protocol PropertyFilterDelegate {
    func updateView()
}
class RightPanelViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBAction func applyFilter(sender: AnyObject) {
        self.view.endEditing(true)
        do {
            try context?.save()
        } catch _ {
        }
              self.dismissViewControllerAnimated(true, completion: nil)      //  delegate?.updateView()
        // delegate?.collapseFilterPanel()
    }
    @IBOutlet var tableView: UITableView!
    //var fetchedResultsController: NSFetchedResultsController? = nil
    var colorsFilter = [String]()
    var context: NSManagedObjectContext?
    var dataHelper: DataHelper?
    var categoryId:Int = 0
    //var delegate: RightPanelViewControllerDelegate?
    
    
    struct TableView {
        struct CellIdentifiers {
            static let SwitchCell = "SwitchCell" //type_id: 2
            static let WheelCell = "WheelCell" //type_id: 3
        }
    }
    
    func performFetch() {
        tableView.reloadData()
    }
    
    var properties:[Property]?
    
    func fetchResults() {
        
        properties = dataHelper?.fetchPropertiesByCategory(categoryId)
        
        var reqStr = ""
        var counter = 0
        for property in properties! {
            reqStr += "propertyId == " + String(property.propertyId)
            if ++counter < properties?.count {
                reqStr += " or "
            }
            
        }
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
        self.dataHelper?.clearPropertiesParams()
        fetchResults()
        performFetch()
    }
    
    
    @IBAction func onBackTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
        //  delegate?.collapseFilterPanel()
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
        
        if properties![section].filterItems.count == 0 {
            return 0
        }
        
        let filterItem = properties![section].filterItems.allObjects[0] as! FilterItem
        
        let cellTypeId = filterItem.property.typeId
        
        var count:Int
        
        switch cellTypeId {
        case Consts.ListTypeID:
            count = properties![section].filterItems.count
            break
        case Consts.OneChoiceListTypeID:
            count = properties![section].filterItems.count
            break
        default:
            count = 1
            break
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let filterItem = getFilterItemBy(indexPath)
        let filterItems = properties![indexPath.section].filterItems
        
        var identifier: String
        
        let cellTypeId = filterItem.property.typeId
        switch cellTypeId {
        case Consts.ListTypeID:
            identifier = TableView.CellIdentifiers.SwitchCell
            break
        case Consts.OneChoiceListTypeID:
            identifier = TableView.CellIdentifiers.SwitchCell
            break
        default:
            identifier = TableView.CellIdentifiers.WheelCell
            break
        }
        var cell:UITableViewCell
        
        if identifier == TableView.CellIdentifiers.SwitchCell {
            let swithcCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SwitchTableViewCell
            swithcCell.titleLabel.text = filterItem.param
            swithcCell.filterItem = filterItem
            cell = swithcCell
        } else {
            let wheelCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! WheelTableViewCell
            
            let filterItems = filterItems.allObjects as! [FilterItem]
            
            let sorted = filterItems.sort({ (el1, el2) -> Bool in
                return el1.position < el2.position
            })
            
            wheelCell.filterItems = sorted
            
            // wheelCell.pickerView.selectRow(0, inComponent: 0, animated: false)
            //wheelCell.pickerView.selectRow(sorted.count-1, inComponent: 1, animated: false)
            
            cell = wheelCell
        }
        
        /*if filterItem.param != "+" && (filterItem.property.name.containsString("цена") || filterItem.property.name.containsString("Цена")) {
        if indexPath.row == 0  {
        cell.titleLabel.text = "от " + filterItem.param
        } else {
        cell.titleLabel.text = "до " + filterItem.param
        }
        }
        else {
        
        }*/
        return cell
    }
    
    func getFilterItemBy(indexPath: NSIndexPath) -> FilterItem {
        let property = self.properties![indexPath.section]
        
        if property.name.containsString("цена") || property.name.containsString("Цена") {
            let items = property.filterItems.allObjects as! [FilterItem]
            if(items.count == 2) {
                if Int(items[0].param) > Int(items[1].param) {
                    if indexPath.row == 0 {
                        return items[1]
                    } else {
                        return items[0]
                    }
                    
                } else {
                    if indexPath.row == 0 {
                        return items[0]
                    } else {
                        return items[1]
                    }
                }
            } else {
                let filterItem = property.filterItems.allObjects[indexPath.row] as! FilterItem
                return filterItem
            }
        } else {
            
            let filterItem = property.filterItems.allObjects[indexPath.row] as! FilterItem
            
            // var propListValues = self.dataHelper?.fetchPropertyListValuesBy(filterItem.property.propertyId)
            
            // propListValues![indexPath.row] as String
            
            return filterItem
        }
        
        
    }
    
}
extension RightPanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let filterItem = getFilterItemBy(indexPath)
        
        var height: CGFloat
        
        let cellTypeId = filterItem.property.typeId
        switch cellTypeId {
        case Consts.ListTypeID:
            height = 44
            break
        case Consts.OneChoiceListTypeID:
            height = 44
            break
        default:
            height = 144
            break
        }
        return height
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //let propertyListValue = fetchedResultsController!.objectAtIndexPath(indexPath) as! Property_Item_List
        //let property = dataHelper!.fetchPropertyBy(propertyListValue.propertyId)
        /* let filterItem = getFilterItemBy(indexPath)
        
        let name = filterItem.property.name
        if name.containsString("цена") || name.containsString("Цена")
        {
        self.performSegueWithIdentifier("ToPriceEditor", sender: filterItem)
        }
        else {
        self.performSegueWithIdentifier("ToPropertyEditor", sender: filterItem)
        }*/
        
    }
    
}
class WheelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pickerView: UIPickerView!
    override
    func layoutSubviews()
    {
        super.layoutSubviews()
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.selectRow(filterItems.count-1, inComponent: 1, animated: false)
        
    }
    var filterItems = [FilterItem]()
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterItems.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var ret: String
        
        if filterItems[row].property.typeId == Consts.NumTypeID {
            ret = String(filterItems[row].paramInt)
        } else {
            ret = filterItems[row].param
        }
        
        return ret
    }
}

class SwitchTableViewCell: UITableViewCell {
    
    var filterItem: FilterItem?
    
    @IBOutlet weak var uiSwitch: UISwitch!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        uiSwitch.reloadInputViews()
        uiSwitch.setOn((filterItem?.selected)!, animated: false)
        
    }
    @IBAction func switchTapped(sender: AnyObject) {
        
        filterItem?.selected =  (sender as! UISwitch).on
        
    }
    @IBOutlet weak var titleLabel: UILabel!
    
}

extension RightPanelViewController: PropertyFilterDelegate {
    
    func updateView() {
        performFetch()
    }
}

