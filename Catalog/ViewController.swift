//
//  ViewController.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import UIKit
import Alamofire
import DATAStack
import Sync

let dataStack = DATAStack(modelName: "Catalog")


class ViewController: UIViewController {
    
    func fetchEntryByTitle(title: String) -> String? {
        
        let fReq = NSFetchRequest(entityName: "Category")
        //fReq.predicate = NSPredicate(format: "'%@' == title", argumentArray: [title])
        var res:String?
        
        var fetchResults : [Category]
        do {
            try fetchResults = dataStack.mainContext.executeFetchRequest(fReq) as! [Category]
            res = fetchResults[0].name
            
        }
        catch {
        }
        return res
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func errProcess(err:NSError!){
            
            let _ = fetchEntryByTitle("");
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

