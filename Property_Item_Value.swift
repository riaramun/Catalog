//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

@objc(Property_Item_Value)
class Property_Item_Value: NSManagedObject {
    
    @NSManaged var id: Int
    @NSManaged var itemId: Int
    @NSManaged var propertyId: Int
    @NSManaged var value: String
    
}