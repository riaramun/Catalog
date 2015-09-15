//
//  ViewController.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(.GET, "http://rezmis3k.bget.ru/demo/sql2.php")
            .responseJSON { _, _, result in
                let categories = JSON(result.value)?[key:"Category"] as? NSArray
                let element = categories![0]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

