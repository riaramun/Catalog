//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import CoreData

protocol RightPanelViewControllerDelegate {
    func collapsePanel()
}

class RightPanelViewController: UIViewController  {
    
    var context: NSManagedObjectContext?
    var dataHelper: DataHelper?
    
    @IBOutlet weak var maxPrice: UITextField!
    @IBOutlet weak var minPrice: UITextField!
   
    @IBAction func applyFilter(sender: AnyObject) {
         self.view.endEditing(true)
        self.dataHelper?.filterItemsByPrice( Int(self.minPrice.text!)!, max: Int(self.maxPrice.text!)!, currentPrice: true)
        delegate?.collapsePanel()
    }
    
    @IBAction func resetFilter(sender: AnyObject) {
         self.view.endEditing(true)
        self.minPrice.text = "0"
        self.maxPrice.text = "0"
        self.dataHelper?.resetfilter()
        delegate?.collapsePanel()
    }
    var delegate: RightPanelViewControllerDelegate?
   
    @IBAction func onBackTapped(sender: AnyObject) {
        self.view.endEditing(true)
        delegate?.collapsePanel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataHelper = DataHelper(context: self.context!)
        
        self.maxPrice.delegate = self
        self.minPrice.delegate = self
    }
}

extension RightPanelViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        maxPrice.resignFirstResponder()
        minPrice.resignFirstResponder()
        return true;
    }
}

extension RightPanelViewController: UIPickerViewDelegate {
    
}