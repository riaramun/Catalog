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


class PriceEditorViewController: UIViewController {
    
    var dataHelper: DataHelper?
    var delegate: RightPanelViewController?
    var propertyId: Int?
    var property: Property?
    
    var context: NSManagedObjectContext?
    @IBOutlet weak var maxPrice: UITextField!
    @IBOutlet weak var minPrice: UITextField!
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataHelper = DataHelper(context: self.context!)
        property = dataHelper?.fetchPropertyBy(propertyId!)
        
        self.title = property!.name
        
        self.maxPrice.delegate = self
        self.minPrice.delegate = self
        
        let filterItems = property?.filterItems.allObjects as! [FilterItem]
        if filterItems.count == 2 {
            if Int(filterItems[0].param) > Int(filterItems[1].param) {
                self.maxPrice.text = filterItems[0].param
                self.minPrice.text = filterItems[1].param
            } else {
                self.maxPrice.text = filterItems[1].param
                self.minPrice.text = filterItems[0].param
            }
        } else {
            self.maxPrice.text = "0"
            self.minPrice.text = "0"
        }
    }
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            
            var params = [String]()
            params.append(self.maxPrice.text!)
            params.append(self.minPrice.text!)
            dataHelper!.clearParams(property!)
            
            if(params[0] == "0" && params[1] == "0") {
                dataHelper?.setEmptyFilterItem(property!)
            }
            else {
                dataHelper?.updateFilterItem(params, property:property!);
            }
            do {
                try self.context!.save()
            } catch {
                
            }
            delegate?.updateView()
        }
    }
    
}

extension PriceEditorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        maxPrice.resignFirstResponder()
        minPrice.resignFirstResponder()
        return true;
    }
}

