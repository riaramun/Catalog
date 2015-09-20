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
        func errProcess(err:NSError!){
            
            //let _ = fetchEntryByTitle("");
        }
        
        Alamofire.request(.GET, "http://rezmis3k.bget.ru/demo/sql2.php")
            .responseJSON { _, _, result in
                let categories = JSON(result.value)?[key:"Category"] as? NSArray
                //let element  = categories![0]
                Sync.changes(
                    categories as! [AnyObject],
                    inEntityNamed: "Category",
                    dataStack: dataStack,
                    completion: errProcess)
        }
    }
}