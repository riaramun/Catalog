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

protocol CoreDataListener {
    func dataUpdated(result:Bool)
    func skipUpdated(date:String)
}
class DataHelper {
    
    var delegate : CoreDataListener?
    static let dataStack = DATAStack(modelName: "Catalog")
    
    class GoodAtribute {
        init(position:Int, property:Property, name:String , value:String, dimen:String, style:String, color:String) {
            self.position = position
            self.property = property
            self.name = name
            self.dimen = dimen
            self.value = value
            self.style = style
            self.color = color
            values = [String]()
        }
        var position:Int
        var property:Property
        var name:String
        var value:String
        var dimen:String
        var style:String
        var color:String
        //this field is used as array of values, it contains the same data as value, but as array, used in filter
        var values:[String]
    }
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /*
    @Returns attributes for particular item, used in collection view
    */
    
    var goodAttributesHash = [String: [String: GoodAtribute]]()
    
    func fetchGoodAttributesBy(itemId: Int, categoryId: Int) -> [String: GoodAtribute] {
        
        let hashKey = String(categoryId) + String(itemId)
        
        if goodAttributesHash[hashKey] != nil {
            return goodAttributesHash[hashKey]!
        }
        
        var goodAttributes = [String: GoodAtribute]()
        
        let propertyItemValues = fetchPropertyItemValuesByItemId(itemId)
        
        for  var i = 0 ; i < propertyItemValues.count;  i++ {
            
            let propertyItemValue  = propertyItemValues[i] as Property_Item_Value
            
            let property = self.fetchPropertyBy(propertyItemValue.propertyId)
            
            var properVal: String = ""
            
            if property!.typeId == Consts.NumTypeID {
                properVal = String(propertyItemValue.value)
            } else if property!.typeId == Consts.ListTypeID || property!.typeId == Consts.OrderedListTypeID {
                if fetchPropertyListValueBy(propertyItemValue.value) != nil {
                    properVal = (fetchPropertyListValueBy(propertyItemValue.value)?.value)!
                }
            } else if property!.typeId == Consts.OneChoiceListTypeID {
                let properListVal = fetchPropertyListValueBy(propertyItemValue.value)
                if properListVal != nil {
                    properVal = (properListVal?.value)!
                }
            }
            
            
            let propertyId = propertyItemValue.propertyId
            
            let propertyItemList = fetchPropertyItemListBy(propertyId, categoryId: categoryId)
            
            let pos = propertyItemList == nil ? 1 : propertyItemList!.position
            
            if goodAttributes[property!.name] == nil {
                
                let goodAtribute = GoodAtribute(
                    position: pos,
                    property:property!,
                    name: property!.name,
                    value: properVal,
                    dimen: property!.dimension,
                    style: property!.style,
                    color: property!.color)
                goodAttributes[property!.name] = goodAtribute
                
                goodAtribute.values.append(properVal)
                
            } else {
                let goodAtribute = goodAttributes[property!.name]
                goodAtribute?.value += ","
                goodAtribute?.value += properVal
                goodAtribute?.values.append(properVal)
            }
        }
        
        goodAttributesHash[hashKey] = goodAttributes
        return goodAttributes
    }
    
    
    
    func fetchPropertyItemListBy(propertyId: Int, categoryId: Int) -> Property_Item_List?
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_List")
        fReq.predicate = NSPredicate(format: "propertyId == %d and categoryId == %d", propertyId, categoryId)
        
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
    func fetchPropertyItemListById(id: Int) -> Property_Item_List?
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_List")
        fReq.predicate = NSPredicate(format: "id == %d", id )
        
        var fetchRes:Property_Item_List?
        do {
            let fetchResults = try self.context.executeFetchRequest(fReq) as! [Property_Item_List]
            if fetchResults.count > 0 {
                fetchRes = fetchResults[0]
            }
        }
        catch {
        }
        return fetchRes
    }
    func fetchPropertyItemValueById(id: Int) -> Property_Item_Value?
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_Value")
        fReq.predicate = NSPredicate(format: "id == %d", id )
        
        var fetchRes:Property_Item_Value?
        do {
            let fetchResults = try self.context.executeFetchRequest(fReq) as! [Property_Item_Value]
            if fetchResults.count > 0 {
                fetchRes = fetchResults[0]
            }
        }
        catch {
        }
        return fetchRes
    }
    
    func fetchPropertyItemValuesBySelectedVal(propertyId: Int, selectedVal: String) -> [Property_Item_Value]
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_Value")
        fReq.predicate = NSPredicate(format: "propertyId == %d and value == '" + selectedVal + "'")
        
        var fetchResults = [Property_Item_Value] ()
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as! [Property_Item_Value]
        }
        catch {
        }
        return fetchResults
    }
    
    func fetchPropertyItemValuesByMinMax(propertyId: Int, min: Int, max: Int) -> [Property_Item_Value]
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_Value")
        fReq.predicate = NSPredicate(format: "propertyId == %d and value > %d and value < %d", propertyId, min, max)
        
        var fetchResults = [Property_Item_Value] ()
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as! [Property_Item_Value]
        }
        catch {
        }
        return fetchResults
    }
    
    func fetchPropertyItemValuesByItemId(itemId: Int) -> [Property_Item_Value]
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
    
    func fetchPropertyItemValuesByPropId(propId: Int) -> [Property_Item_Value]
    {
        let fReq = NSFetchRequest(entityName: "Property_Item_Value")
        fReq.predicate = NSPredicate(format: "propertyId == %d", propId)
        
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
    /*func fetchPropertyListValuesBy(propId: Int, listId: Int) -> [Property_List_Value]?
    {
    let fReq = NSFetchRequest(entityName: "Property_List_Value")
    fReq.predicate = NSPredicate(format: "propertyId == %d and listId == %d", propId, listId )
    let primarySortDescriptor = NSSortDescriptor(key: "position", ascending: true)
    fReq.sortDescriptors = [primarySortDescriptor]
    
    var fetchResults : [Property_List_Value]?
    do {
    try fetchResults = self.context.executeFetchRequest(fReq) as? [Property_List_Value]
    }
    catch {
    }
    return fetchResults!
    }*/
    func fetchPropertyListValuesBy(propId: Int) -> [Property_List_Value]?
    {
        let fReq = NSFetchRequest(entityName: "Property_List_Value")
        fReq.predicate = NSPredicate(format: "propertyId == %d", propId )
        let primarySortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fReq.sortDescriptors = [primarySortDescriptor]
        
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
        return res
    }
    
    func getSettings() {
        
        Alamofire.request(.GET, Consts.URL_SITE + Consts.CHECK_VER_PARAM )
            .responseJSON { _, resp, result in
                
                if result.isFailure == true {
                    self.delegate!.dataUpdated(false)
                    return
                } else {
                    
                    let obj = JSON(result.value);
                    
                    let date_update = obj?[key:"date_update"] as! String
                    let title_image = obj?[key:"title_image"] as! String
                    let logo = obj?[key:"logo"] as! String
                    let codew = obj?[key:"codew"] as! String
                    let name = obj?[key:"name"] as! String
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    
                    var toUpdate = false
                    if let old_date_update = userDefaults.valueForKey("date_update")  {
                        if date_update != old_date_update as! String {
                            toUpdate = true
                        } else {
                            toUpdate = false
                        }
                    }
                    else {
                        
                        toUpdate = true
                    }
                    
                    userDefaults.setValue(date_update, forKey: "date_update")
                    userDefaults.setValue(title_image, forKey: "title_image")
                    userDefaults.setValue(logo, forKey: "logo")
                    userDefaults.setValue(codew, forKey: "codew")
                    userDefaults.setValue(name, forKey: "name")
                    userDefaults.synchronize()
                    
                    if toUpdate {
                        self.seedDataStore()
                    } else {
                        //we need init filter items here for each property
                        self.delegate!.skipUpdated(date_update)
                    }
                    
                    
                    
                }
        }
        
    }
    func seedDataStore() {
        
        //dataStack.drop()
        
        Alamofire.request(.GET, Consts.URL_SITE + Consts.URL_REQ_PARAM )
            .responseJSON { _, resp, result in
                
                if result.isFailure == true {
                    self.delegate!.dataUpdated(false)
                    return
                }
                
                
                let categories = JSON(result.value)?[key:"Category"] as? NSArray
                let items = JSON(result.value)?[key:"Item"] as? NSArray
                let item_photos = JSON(result.value)?[key:"Item_Photo"] as? NSArray
                let property_item_values = JSON(result.value)?[key:"Property_Item_Value"] as? NSArray
                let properties = JSON(result.value)?[key:"Property"] as? NSArray
                let propertyItemList = JSON(result.value)?[key:"Property_Item_List"] as? NSArray
                let propertyListValue = JSON(result.value)?[key:"Property_List_Value"] as? NSArray
                
                
                
                
                func itemPhotosAdded(err:NSError!) {
                    
                    do {
                        try self.context.save()
                    } catch {
                        
                    }
                    
                    //we need init filter items here for each property
                    self.seedFilterItems()
                    
                    do {
                        try self.context.save()
                    } catch {
                        
                    }
                    
                    
                    if self.delegate != nil {
                        self.delegate!.dataUpdated(true)
                    }
                    
                }
                
                func propertyItemValuesAdded(err:NSError!) {
                    if(item_photos != nil ) {
                        Sync.changes(
                            item_photos as! [AnyObject],
                            inEntityNamed: "Item_Photo",
                            dataStack: DataHelper.dataStack,
                            completion: itemPhotosAdded)
                    }
                }
                
                func propertyListValueAdded(err:NSError!) {
                    
                    if(property_item_values != nil ) {
                        var counter = 0
                        for val in property_item_values! {
                            
                            let obj = JSON(val);
                            
                            let itemId = obj?[key:"item_id"] as! Int
                            let propertyId = obj?[key:"property_id"] as! Int
                            
                            let value = obj?[key:"value"] is String ? Int (obj?[key:"value"] as! String ) : obj?[key:"value"] as? Int
                            
                            let id = counter
                            
                            let propertyItemValue = self.fetchPropertyItemValueById(counter)
                            if propertyItemValue != nil {
                                propertyItemValue?.id = counter
                                propertyItemValue?.itemId = itemId
                                propertyItemValue?.propertyId = propertyId
                                propertyItemValue?.value = value!
                            } else
                            {
                                let entity = NSEntityDescription.entityForName("Property_Item_Value", inManagedObjectContext: self.context)
                                
                                let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                                
                                item.setValue(id, forKey: "id")
                                item.setValue(itemId, forKey: "ItemId")
                                item.setValue(propertyId, forKey: "propertyId")
                                item.setValue(value, forKey: "value")
                            }
                            ++counter
                            //let itemGood = self.fetchItemById(itemId)
                            //item.setValue(itemGood, forKey: "item")
                            
                            
                            //  let itemProp = self.fetchPropertyBy(propertyId)
                            //  item.setValue(itemProp, forKey: "property")
                            
                        }
                        do {
                            try self.context.save()
                            
                        } catch {
                        }
                        propertyItemValuesAdded(nil)
                    }
                }
                
                func propertyItemListAdded(err:NSError!) {
                    
                    if(propertyListValue != nil ) {
                        Sync.changes(
                            propertyListValue as! [AnyObject],
                            inEntityNamed: "Property_List_Value",
                            dataStack: DataHelper.dataStack,
                            completion: propertyListValueAdded)
                    }
                }
                
                func propertiesAdded(err:NSError!) {
                    
                    if(propertyItemList != nil ) {
                        var counter = 0
                        for val in propertyItemList! {
                            
                            let obj = JSON(val);
                            
                            let propertyItemList = self.fetchPropertyItemListById(counter)
                            
                            if propertyItemList != nil {
                                
                                propertyItemList?.id = counter
                                propertyItemList?.categoryId = obj?[key:"category_id"] as! Int
                                propertyItemList?.propertyId = obj?[key:"property_id"] as! Int
                                propertyItemList?.position = obj?[key:"position"] as! Int
                                
                            } else {
                                
                                let entity = NSEntityDescription.entityForName("Property_Item_List", inManagedObjectContext: self.context)
                                let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                                
                                let id = counter
                                
                                item.setValue(id, forKey: "id")
                                item.setValue(obj?[key:"category_id"] as! Int, forKey: "categoryId")
                                item.setValue(obj?[key:"property_id"] as! Int, forKey: "propertyId")
                                item.setValue(obj?[key:"position"] as! Int, forKey: "position")
                            }
                            ++counter
                        }
                        do {
                            try self.context.save()
                            
                        } catch {
                        }
                        propertyItemListAdded(nil)
                    }
                }
                
                func itemsAdded(err:NSError!) {
                    if(properties != nil ) {
                        Sync.changes(
                            properties as! [AnyObject],
                            inEntityNamed: "Property",
                            dataStack: DataHelper.dataStack,
                            completion: propertiesAdded)
                    }
                }
                
                
                func categoriesAdded(err:NSError!) {
                    if(items != nil ) {
                        Sync.changes(
                            items as! [AnyObject],
                            inEntityNamed: "Item",
                            dataStack: DataHelper.dataStack,
                            completion: itemsAdded)
                    }
                }
                
                if(categories != nil ) {
                    Sync.changes(
                        categories as! [AnyObject],
                        inEntityNamed: "Category",
                        dataStack: DataHelper.dataStack,
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
    func fetchItemById(itemId:Int) -> Item
    {
        let fReq = NSFetchRequest(entityName: "Item")
        fReq.predicate = NSPredicate(format: "itemId == %d", itemId)
        
        
        var fetchResults : [Item]?
        do {
            try fetchResults = self.context.executeFetchRequest(fReq) as? [Item]
        }
        catch {
        }
        return fetchResults![0]
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
    
    func filterItemsByParams(categoryId:Int)  {
        
        let items = fetchItemsBy(categoryId);
        
        for item in items! {
            
            let goodAttributes = fetchGoodAttributesBy(item.itemId, categoryId: categoryId)
            
            var skip = false
            
            for goodAttribute in goodAttributes.values {
                
                let property = goodAttribute.property
                
                if property.typeId == Consts.NumTypeID {
                    
                    if property.propertyId == 1 || property.propertyId == 2 {
                        
                        let currPrice = Int(goodAttribute.value)
                        
                        let min = Int(property.minVal)
                        
                        let max = Int(property.maxVal)
                        
                        if min != nil && max != nil {
                            
                            if currPrice >= min && currPrice <= max {
                                //nothing to do
                            } else {
                                //we don't need to check other property values
                                //since the item price is out of selected bounds
                                skip = true
                                break
                            }
                        }
                    } else {
                        
                    }
                    
                } else {
                    
                    let min = Int(property.minVal)
                    let max = Int(property.maxVal)
                    
                    if min != nil && max != nil {
                        skip = true
                        for value in goodAttribute.values {
                            //this means that it is height or somthing like this
                            let intVal = Int(value)
                            if  min <= intVal && intVal <= max {
                                skip = false
                                break
                            }
                        }
                        
                    } else {
                        
                        var coincidenceFound = false
                        var isSelectedFilter = false
                        
                        for filterItem in property.filterItems.allObjects as! [FilterItem] {
                            
                            if filterItem.selected {
                                isSelectedFilter = true
                                if goodAttribute.value.containsString(filterItem.param) {
                                    coincidenceFound = true
                                    //this filter item is confirmed
                                }
                                else {
                                    //we don't need to check other property values
                                    //since this filter items in not satisfied
                                    //break
                                    
                                }
                            }
                        }
                        if isSelectedFilter {
                            if coincidenceFound {
                                skip = false
                            } else {
                                skip = true
                            }
                        }
                        else {
                            skip = false
                        }
                    }
                }
                if skip {
                    break
                }
            }
            item.visible = !skip
        }
    }
    
    /*    func filterItemsByParams(categoryId:Int)  {
    
    let items = fetchItemsBy(categoryId);
    
    for item in items! {
    
    var skip = false
    
    //the next step is to check the item for filters conditions
    let propertyItemValues = fetchPropertyItemValuesByItemId(item.itemId)
    
    for propertyItemValue in propertyItemValues {
    
    let property = fetchPropertyBy(propertyItemValue.propertyId)
    
    if property!.typeId == Consts.NumTypeID {
    
    let currPrice = propertyItemValue.value
    let min = Int(property!.minVal)
    let max = Int(property!.maxVal)
    if min != nil && max != nil {
    if currPrice >= min && currPrice <= max {
    //nothing to do
    } else {
    //we don't need to check other property values
    //since the item price is out of selected bounds
    skip = true
    break
    
    }
    }
    
    } else {
    
    let propertyListValue = self.fetchPropertyListValueBy(propertyItemValue.value)
    print(propertyListValue?.value)
    
    var foundCoincidence = false
    for filterItem in property!.filterItems.allObjects as! [FilterItem] {
    if filterItem.selected == true {
    if filterItem.param == propertyListValue {
    foundCoincidence = true
    //we found that the property is in selected filter
    break
    }
    }
    }
    }
    }
    item.visible = !skip
    }
    do {
    try self.context.save()
    } catch {
    
    }
    
    }
    
    func filterItemsByParams2(categoryId:Int)
    {
    let items = fetchItemsBy(categoryId);
    var counter:Int = 0
    
    for item in items! {
    counter++
    let propertiesValues = fetchPropertyItemValuesByItemId(item.itemId)
    
    //var properVal: Int = 1
    
    for var i = 0 ; i < propertiesValues.count;  i++ {
    
    let propertiesValue  = propertiesValues[i] as Property_Item_Value
    
    let property = fetchPropertyBy(propertiesValue.propertyId)
    
    
    let filterItems = property?.filterItems.allObjects as! [FilterItem]
    
    
    if filterItems.count > 0 && filterItems[0].param != "+" {
    
    item.position = -1
    
    if property?.name.lowercaseString == "цена"  || property?.name.lowercaseString == "старая цена" {
    let price = Int(propertiesValue.value)
    var max = 0
    var min = 0
    if Int(filterItems[0].param)! > Int(filterItems[1].param)! {
    max = Int(filterItems[0].param)!
    min = Int(filterItems[1].param)!
    } else {
    max = Int(filterItems[0].param)!
    min = Int(filterItems[1].param)!
    }
    if(price >= min && price <= max) {
    item.position = counter
    break
    }
    }
    else {
    for filterItem in filterItems {
    
    let propertyListValue = self.fetchPropertyListValueBy(propertiesValue.value)
    
    if filterItem.param == propertyListValue!.value {
    
    item.position = counter
    
    break
    }
    }
    }
    if item.position == -1 {
    break
    }
    }
    if item.position == -1 {
    break
    }
    }
    }
    
    do {
    try self.context.save()
    } catch {
    
    }
    }*/
    
    
    func sortItemsByCurrentPrice(categoryId: Int, increase:Bool, currentPrice:Bool)
    {
        let items = fetchItemsBy(categoryId);
        
        var itemsDictanary = [Item:Int]()
        
        for item in items! {
            
            let propertiesValues = fetchPropertyItemValuesByItemId(item.itemId)
            
            var properVal: Int = 1
            
            for var i = 0 ; i < propertiesValues.count;  i++ {
                
                let propertiesValue  = propertiesValues[i] as Property_Item_Value
                
                let property = fetchPropertyBy(propertiesValue.propertyId)
                
                if(currentPrice) {
                    if property?.name.lowercaseString == "цена"  {
                        
                        properVal = propertiesValue.value
                        
                        break
                    }
                } else {
                    if property?.name.lowercaseString == "старая цена"  {
                        
                        properVal = propertiesValue.value
                        
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
            } else {
                
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
        fReq.predicate = NSPredicate(format: "categoryId == %d ", id)
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
            
            let propListValues = fetchPropertyListValuesBy(property.propertyId)
            
            if propListValues?.count > 0 {
                for propListValue in propListValues! {
                    
                    let entity = NSEntityDescription.entityForName("FilterItem", inManagedObjectContext: self.context)
                    let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                    item.setValue(propListValue.position, forKey: "position")
                    item.setValue(property, forKey: "property")
                    item.setValue(propListValue.value, forKey: "param")
                    item.setValue(propListValue.listId, forKey: "listId")
                    item.setValue(false, forKey: "selected")
                    
                    /* let filterItem = NSEntityDescription.insertNewObjectForEntityForName("FilterItem", inManagedObjectContext: self.context) as! FilterItem
                    filterItem.position = propListValue.position
                    filterItem.property = property
                    filterItem.param = propListValue.value
                    filterItem.listId = propListValue.listId
                    filterItem.selected = false*/
                }
            }
            else {
                //if property doesn't have Property_List_Value array it means that it is a number
                //so we need to find all nambers which we have in corresponding Property_Item_Value table
                let hashSet = NSMutableSet()
                
                let propertyItemValues = fetchPropertyItemValuesByPropId(property.propertyId)
                for propItemValue in propertyItemValues {
                    if hashSet.containsObject(propItemValue.value) {
                        continue
                    }
                    hashSet.addObject(propItemValue.value)
                    
                    let entity = NSEntityDescription.entityForName("FilterItem", inManagedObjectContext: self.context)
                    let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.context)
                    
                    item.setValue(propItemValue.value, forKey: "position")
                    item.setValue(property, forKey: "property")
                    item.setValue(propItemValue.value, forKey: "paramInt")
                    // item.setValue(propListValue.listId, forKey: "listId")
                    item.setValue(false, forKey: "selected")
                    
                    
                    /* let filterItem = NSEntityDescription.insertNewObjectForEntityForName("FilterItem", inManagedObjectContext: self.context) as! FilterItem
                    //filterItem.position = propListValue.position
                    filterItem.property = property
                    filterItem.paramInt = propItemValue.value
                    //we use position param as sort key, so we put there int value
                    filterItem.position = propItemValue.value
                    //filterItem.listId = propListValue.listId!!
                    filterItem.selected = false*/
                }
            }
        }
    }
    func clearParams(property:Property){
        for entity in (property.filterItems) {
            self.context.deleteObject(entity as! NSManagedObject)
        }
    }
    /*func clearPropertiesParams(){
    let properties = fetchAllProperties()
    for property in properties! {
    for entity in (property.filterItems) {
    self.context.deleteObject(entity as! NSManagedObject)
    }
    setEmptyFilterItem(property)
    }
    }*/
    func updateFilterItem(params:[String], property:Property)
    {
        for param in params {
            let entity = NSEntityDescription.insertNewObjectForEntityForName("FilterItem", inManagedObjectContext: self.context) as! FilterItem
            entity.param = param
            entity.property = property
        }
    }
    /*func setEmptyFilterItem(property:Property) {
    let entity = NSEntityDescription.insertNewObjectForEntityForName("FilterItem", inManagedObjectContext: self.context) as! FilterItem
    entity.param = "+"
    entity.property = property
    }*/
    
    func getPhotoFor(itemId:Int) -> String? {
        let fetchRequest = NSFetchRequest(entityName: "Item_Photo")
        fetchRequest.predicate = NSPredicate(format: "%d == itemId", itemId)
        var photo:String?
        do {
            var res:Item_Photo?
            try res = self.context.executeFetchRequest(fetchRequest).first as? Item_Photo
            photo = res?.photo
        }
        catch {
        }
        return photo
    }
    func fetchPropListValBy(propertyId:Int) -> [Property_List_Value]?
    {
        let fetchRequest = NSFetchRequest(entityName: "Property_List_Value")
        fetchRequest.predicate = NSPredicate(format: "propertyId == %d", propertyId )
        let primarySortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        var properties: [Property_List_Value]?
        
        do {
            try properties = self.context.executeFetchRequest(fetchRequest) as? [Property_List_Value]
        }
        catch {
        }
        return properties
    }
}