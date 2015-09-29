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
                let item_photos = JSON(result.value)?[key:"Item_Photo"] as? NSArray
                let property_item_values = JSON(result.value)?[key:"Property_Item_Value"] as? NSArray
                let properties = JSON(result.value)?[key:"Property"] as? NSArray
                
                func propertiesAdded(err:NSError!) {
                    
                }
                
                func propertyItemValuesAdded(err:NSError!) {
                    if(properties != nil ) {
                        Sync.changes(
                            properties as! [AnyObject],
                            inEntityNamed: "Property",
                            dataStack: dataStack,
                            completion: propertiesAdded)
                    }
                }
                
                func itemPhotosAdded(err:NSError!) {
                    if(property_item_values != nil ) {
                        var counter = 0
                        for val in property_item_values! {
                            
                            let entity = NSEntityDescription.entityForName("Property_Item_Value", inManagedObjectContext: self.context)
                            
                            let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                            
                            let obj = JSON(val);
                            
                            let itemId = obj?[key:"item_id"] as! Int
                            let propertyId = obj?[key:"property_id"] as! Int
                            let value =
                            obj?[key:"value"] is String ? obj?[key:"value"] as! String : String (obj?[key:"value"] as! Int)
                            
                            let id = ++counter
                            item.setValue(id, forKey: "id")
                            item.setValue(itemId, forKey: "ItemId")
                            item.setValue(propertyId, forKey: "propertyId")
                            item.setValue(value, forKey: "value")
                        }
                        do {
                            try self.context.save()
                        } catch {
                            
                        }
                        propertyItemValuesAdded(nil)
                        /*Sync.changes(
                            property_item_values as! [AnyObject],
                            inEntityNamed: "Property_Item_Value",
                            dataStack: dataStack,
                            completion: propertyItemValuesAdded)*/
                    }
                }
                
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
                    if(item_photos != nil ) {
                        Sync.changes(
                            item_photos as! [AnyObject],
                            inEntityNamed: "Item_Photo",
                            dataStack: dataStack,
                            completion: itemPhotosAdded)
                    }
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