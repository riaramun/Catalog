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
    
    class GoodAtribute {
        init(name:String , value:String, dimen:String) {
            self.name = name
            self.dimen = dimen
            self.value = value
        }
        var name:String
        var value:String
        var dimen:String
    }
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchGoodAttributesBy(itemId: Int, categoryId: Int) -> [Int: GoodAtribute] {
        
        
        
        var goodAttributes = [Int: GoodAtribute]()
        
        let propertiesValues = fetchPropertyItemValuesBy(itemId)
        
        for  var i = 0 ; i < propertiesValues.count;  i++ {
            
            
            let propertiesValue  = propertiesValues[i] as Property_Item_Value
            
            let property = fetchPropertyBy(propertiesValue.propertyId)
            
            let propertyItemList = fetchPropertyItemListBy(propertiesValue.propertyId, categoryId: categoryId)
            
            if propertyItemList != nil {
                let goodAtribute = GoodAtribute(name: (property?.name)!,
                    value: propertiesValue.value,
                    dimen: (property?.dimension)!)
                goodAttributes[propertyItemList!.position] = goodAtribute
            }
            
        }
        return goodAttributes
    }
    
    
    
    func fetchPropertyItemListBy(propertyId: Int, categoryId: Int) -> Property_Item_List?
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_List")
        fReq.predicate = NSPredicate(format: "propertyId == %d and  categoryId == %d", propertyId, categoryId)
        
        var fetchResults : [Property_Item_List]
        var property: Property_Item_List?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as! [Property_Item_List]
            property = fetchResults.count > 0 ? fetchResults[0] : nil
        }
        catch {
        }
        return property
    }
    
    func fetchPropertyItemValuesBy(itemId: Int) -> [Property_Item_Value]
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_Value")
        fReq.predicate = NSPredicate(format: "itemId == %d", itemId)
        
        var fetchResults = [Property_Item_Value] ()
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as! [Property_Item_Value]
        }
        catch {
        }
        return fetchResults
    }
    
    func fetchPropertyBy(propertyId: Int) -> Property?
    {
        let fReq = NSFetchRequest(entityName: "Property")
        fReq.predicate = NSPredicate(format: "%d == propertyId", propertyId)
        
        var fetchResults : [Property]
        var property: Property?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as! [Property]
            property = fetchResults.count > 0 ? fetchResults[0] : nil
        }
        catch {
        }
        return property
    }
    
    func seedDataStore() {
        
        Alamofire.request(.GET, "http://rezmis3k.bget.ru/demo/sql2.php")
            .responseJSON { _, resp, result in
                
                let categories = JSON(result.value)?[key:"Category"] as? NSArray
                let items = JSON(result.value)?[key:"Item"] as? NSArray
                let item_photos = JSON(result.value)?[key:"Item_Photo"] as? NSArray
                let property_item_values = JSON(result.value)?[key:"Property_Item_Value"] as? NSArray
                let properties = JSON(result.value)?[key:"Property"] as? NSArray
                let propertyItemList = JSON(result.value)?[key:"Property_Item_List"] as? NSArray
                
                func propertyItemListAdded(err:NSError!) {
                    
                }
                
                func propertiesAdded(err:NSError!) {
                    if(propertyItemList != nil ) {
                        var counter = 0
                        for val in propertyItemList! {
                            
                            let entity = NSEntityDescription.entityForName("Property_Item_List", inManagedObjectContext: self.context)
                            
                            let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                            
                            let obj = JSON(val);
                            
                            let categoryId = obj?[key:"category_id"] as! Int
                            let propertyId = obj?[key:"property_id"] as! Int
                            let position = obj?[key:"position"] as! Int
                            
                            let id = ++counter
                            item.setValue(id, forKey: "id")
                            item.setValue(categoryId, forKey: "categoryId")
                            item.setValue(propertyId, forKey: "propertyId")
                            item.setValue(position, forKey: "position")
                        }
                        do {
                            try self.context.save()
                        } catch {
                            
                        }
                        propertyItemListAdded(nil)
                    }
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