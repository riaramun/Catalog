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
        init(name:String , value:String, dimen:String, style:String, color:String) {
            self.name = name
            self.dimen = dimen
            self.value = value
            self.style = style
            self.color = color
        }
        var name:String
        var value:String
        var dimen:String
        var style:String
        var color:String
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
            
            var properVal: String = ""
            
            if property?.typeId == 1 {
                properVal = propertiesValue.value
            } else if property?.typeId == 2 || property?.typeId == 3 {
                let propList = fetchPropertyListValuesBy((property?.propertyId)!)
                for prop in propList! {
                    properVal += prop.value
                    if propList?.last != prop {
                        properVal += ", "
                    }
                }
            } else if property?.typeId == 4 {
                let properListVal = fetchPropertyListValueBy(Int(propertiesValue.value)!)
                properVal = (properListVal?.value)!
            }
            let propertyItemList = fetchPropertyItemListBy(propertiesValue.propertyId, categoryId: categoryId)
            
            if propertyItemList != nil {
                let goodAtribute = GoodAtribute(name: (property?.name)!,
                    value: properVal,
                    dimen: (property?.dimension)!,
                    style: (property?.style)!,
                    color: (property?.color)!)
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
    func fetchPropertyIdBy(name: String) -> Int?
    {
        let fReq = NSFetchRequest(entityName: "Property")
        fReq.predicate = NSPredicate(format: "name == '" + name + "'")
        
        var fetchResults : [Property]
        var property: Property?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as! [Property]
            property = fetchResults.count > 0 ? fetchResults[0] : nil
        }
        catch {
        }
        return property?.propertyId
    }
    func fetchPropertyListValuesBy(propId: Int) -> [Property_List_Value]?
    {
        let fReq = NSFetchRequest(entityName: "Property_List_Value")
        fReq.predicate = NSPredicate(format: "propertyId == %d", propId )
        
        var fetchResults : [Property_List_Value]?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as? [Property_List_Value]
        }
        catch {
        }
        return fetchResults!
    }
    func fetchPropertyListValueBy(listId: Int) -> Property_List_Value?
    {
        let fReq = NSFetchRequest(entityName: "Property_List_Value")
        fReq.predicate = NSPredicate(format: "listId == %d", listId )
        
        var fetchResults : [Property_List_Value]
        var res: Property_List_Value?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as! [Property_List_Value]
            res = fetchResults.count > 0 ? fetchResults[0] : nil
        }
        catch {
        }
        return res!
    }
    
    func seedDataStore() {
        
        dataStack.drop()
        
        Alamofire.request(.GET, "http://rezmis3k.bget.ru/demo/sql2.php")
            .responseJSON { _, resp, result in
                
                let categories = JSON(result.value)?[key:"Category"] as? NSArray
                let items = JSON(result.value)?[key:"Item"] as? NSArray
                let item_photos = JSON(result.value)?[key:"Item_Photo"] as? NSArray
                let property_item_values = JSON(result.value)?[key:"Property_Item_Value"] as? NSArray
                let properties = JSON(result.value)?[key:"Property"] as? NSArray
                let propertyItemList = JSON(result.value)?[key:"Property_Item_List"] as? NSArray
                let propertyListValue = JSON(result.value)?[key:"Property_List_Value"] as? NSArray
                
                
                func propertyListValueAdded(err:NSError!) {
                    
                    self.seedFilterItems()
                    
                    do {
                        try self.context.save()
                    } catch {
                        
                    }
                }
                
                func propertyItemListAdded(err:NSError!) {
                    
                    if(propertyListValue != nil ) {
                        Sync.changes(
                            propertyListValue as! [AnyObject],
                            inEntityNamed: "Property_List_Value",
                            dataStack: dataStack,
                            completion: propertyListValueAdded)
                    }
                }
                
                func propertiesAdded(err:NSError!) {
                    if(propertyItemList != nil ) {
                        var counter = 0
                        for val in propertyItemList! {
                            let entity = NSEntityDescription.entityForName("Property_Item_List", inManagedObjectContext: self.context)
                            let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                            let obj = JSON(val);
                            let id = ++counter
                            item.setValue(id, forKey: "id")
                            item.setValue(obj?[key:"category_id"] as! Int, forKey: "categoryId")
                            item.setValue(obj?[key:"property_id"] as! Int, forKey: "propertyId")
                            item.setValue(obj?[key:"position"] as! Int, forKey: "position")
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
    
    func fetchAllItems() -> [Item]?
    {
        let fReq = NSFetchRequest(entityName: "Item")
        
        var fetchResults : [Item]?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as? [Item]
        }
        catch {
        }
        return fetchResults
    }
    func fetchItemsBy(categoryId: Int) -> [Item]?
    {
        let fReq = NSFetchRequest(entityName: "Item")
        fReq.predicate = NSPredicate(format: "categoryId == %d", categoryId)
        
        var fetchResults : [Item]?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as? [Item]
        }
        catch {
        }
        return fetchResults
    }
    
    func resetfilter()
    {
        let items = fetchAllItems();
        
        var counter = 0
        
        for item in items! {
            
            item.position = counter++
        }
        
        do {
            try self.context.save()
        } catch {
            
        }
    }
    
    func filterItemsByPrice(min:Int, max:Int, currentPrice:Bool)
    {
        let items = fetchAllItems();
        var counter:Int = 0
        for item in items! {
            counter++
            let propertiesValues = fetchPropertyItemValuesBy(item.itemId)
            
            var properVal: Int = 1
            
            for var i = 0 ; i < propertiesValues.count;  i++ {
                
                let propertiesValue  = propertiesValues[i] as Property_Item_Value
                
                let property = fetchPropertyBy(propertiesValue.propertyId)
                
                if(currentPrice) {
                    if property?.name == "цена" || property?.name == "Цена"  {
                        
                        properVal = Int(propertiesValue.value)!
                        
                        break
                    }
                } else {
                    if property?.name == "Старая цена" || property?.name == "старая цена"  {
                        
                        properVal = Int(propertiesValue.value)!
                        
                        break
                    }
                }
                
            }
            
            if(!( properVal >= min && properVal <= max )) {
                item.position = -1
            }
            else {
                item.position = counter
            }
        }
        
        do {
            try self.context.save()
        } catch {
            
        }
    }
    func sortItemsByCurrentPrice(categoryId: Int, increase:Bool, currentPrice:Bool)
    {
        let items = fetchItemsBy(categoryId);
        
        var itemsDictanary = [Item:Int]()
        
        for item in items! {
            
            let propertiesValues = fetchPropertyItemValuesBy(item.itemId)
            
            var properVal: Int = 1
            
            for var i = 0 ; i < propertiesValues.count;  i++ {
                
                let propertiesValue  = propertiesValues[i] as Property_Item_Value
                
                let property = fetchPropertyBy(propertiesValue.propertyId)
                
                if(currentPrice) {
                    if property?.name == "цена" || property?.name == "Цена"  {
                        
                        properVal = Int(propertiesValue.value)!
                        
                        break
                    }
                } else {
                    if property?.name == "Старая цена" || property?.name == "старая цена"  {
                        
                        properVal = Int(propertiesValue.value)!
                        
                        break
                    }
                }
            }
            itemsDictanary[item] = properVal
        }
        
        
        var sortedKeys = Array(itemsDictanary.keys).sort({itemsDictanary[$0] < itemsDictanary[$1]})
        if !increase {
            sortedKeys = Array(itemsDictanary.keys).sort({itemsDictanary[$0] > itemsDictanary[$1]})
        }
        var counter = 0
        for key in sortedKeys {
            if(key.position != -1) {
                key.position = counter
                counter++
            }
            
        }
        
        do {
            try self.context.save()
        } catch {
            
        }
    }
    func updateItem (item:Item) {
        
        let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: self.context)
        let itemManageObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
        
        itemManageObj.setValue(item.itemId, forKey: "itemId")
        
        itemManageObj.setValue(item.categoryId, forKey: "categoryId")
        itemManageObj.setValue(item.position, forKey: "position")
        
        itemManageObj.setValue(item.shortName, forKey: "shortName")
        itemManageObj.setValue(item.longName, forKey: "longName")
        
        itemManageObj.setValue(item.code, forKey: "code")
        itemManageObj.setValue(item.shortDescr, forKey: "shortDescr")
        
        itemManageObj.setValue(item.longDescr, forKey: "longDescr")
        
    }
    func getProperitesByName(name:String) -> [Property_List_Value]? {
        
        let propertyId = fetchPropertyIdBy(name)
        return fetchPropertyListValuesBy(propertyId!)
    }
    func fetchPropertiesByCategory(id:Int) -> [Property] {
        
        let fReq = NSFetchRequest(entityName: "Property_Item_List")
        fReq.predicate = NSPredicate(format: "categoryId == %d", id)
        let primarySortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fReq.sortDescriptors = [primarySortDescriptor]
        
        var fetchResults : [Property_Item_List]?
        var properties = [Property]()
        
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as? [Property_Item_List]
        }
        catch {
        }
        for propItemList in fetchResults! {
            let property = fetchPropertyBy(propItemList.propertyId)
            properties.append(property!)
        }
        return properties
    }
    func fetchAllProperties() -> [Property]? {
        
        let fReq = NSFetchRequest(entityName: "Property")
        
        var properties: [Property]?
        
        do {
            try properties = self.context.executeFetchRequest(fReq) as? [Property]
        }
        catch {
        }
        return properties
    }
    func seedFilterItems() {
        let properties = fetchAllProperties();
        for property in properties! {
            
            let entity = NSEntityDescription.insertNewObjectForEntityForName("FilterItem", inManagedObjectContext: self.context) as! FilterItem
            
            entity.param = "+"
            entity.property = property
            //entity.name = property.name
            //entity.propertyId = property.propertyId
        }
    }
    func clearParams(property:Property){
        for entity in (property.filterItems) {
            self.context.deleteObject(entity as! NSManagedObject)
        }
    }
    func clearPropertiesParams(){
        let properties = fetchAllProperties()
        for property in properties! {
            for entity in (property.filterItems) {
                self.context.deleteObject(entity as! NSManagedObject)
            }
            setEmptyFilterItem(property)
        }
    }
    func updateFilterItem(params:[String], property:Property)
    {
        for param in params {
            let entity = NSEntityDescription.insertNewObjectForEntityForName("FilterItem", inManagedObjectContext: self.context) as! FilterItem
            entity.param = param
            entity.property = property
           // entity.name = property.name
           // entity.propertyId = property.propertyId
        }
    }
    func setEmptyFilterItem(property:Property) {
        let entity = NSEntityDescription.insertNewObjectForEntityForName("FilterItem", inManagedObjectContext: self.context) as! FilterItem
        entity.param = "+"
        entity.property = property
       // entity.name = property.name
       // entity.propertyId = property.propertyId
    }
}