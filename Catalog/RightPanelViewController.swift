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
    
    @IBOutlet weak var maxPrice: UITextField!
    @IBOutlet weak var minPrice: UITextField!
   
    var delegate: RightPanelViewControllerDelegate?
   
    @IBAction func onBackTapped(sender: AnyObject) {
        self.view.endEditing(true)
        delegate?.collapsePanel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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