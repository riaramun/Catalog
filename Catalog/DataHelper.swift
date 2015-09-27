//
//  DataHelper.swift
//  Catalog
//
//  Created by Admin on 18/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import Alamofire
import DATAStack
import Sync


class DataHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    func seedDataStore() {
        
        
        
        Alamofire.request(.GET, "http://rezmis3k.bget.ru/demo/sql2.php")
            .responseJSON { _, resp, result in
                
                let categories = JSON(result.value)?[key:"Category"] as? NSArray
                let items = JSON(result.value)?[key:"Item"] as? NSArray
                
                func categoriesAdded(err:NSError!) {
                    if(items != nil ) {
                        Sync.changes(
                            items as! [AnyObject],
                            inEntityNamed: "Item",
                            dataStack: dataStack,
                            completion: itemsAdded)
                    }
                }
                func itemsAdded(err:NSError!) {
                    
                }
                if(categories != nil ) {
                Sync.changes(
                    categories as! [AnyObject],
                    inEntityNamed: "Category",
                    dataStack: dataStack,
                    completion: categoriesAdded)
                }
                
        }
    }
}