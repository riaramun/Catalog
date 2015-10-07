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


protocol PriceEditorDelegate {
    func setPrice(values:[String])
}
class PriceEditorViewController: UIViewController {
    
    var delegate: PriceEditorDelegate?
    var propertyName: String = ""
    var context: NSManagedObjectContext?
    @IBOutlet weak var maxPrice: UITextField!
    @IBOutlet weak var minPrice: UITextField!
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = propertyName
        
        self.maxPrice.delegate = self
        self.minPrice.delegate = self
        
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

