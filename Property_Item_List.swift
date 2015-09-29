//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

@objc(Property_Item_List)
class Property_Item_List: NSManagedObject {
    
    @NSManaged var id: Int
    @NSManaged var categoryId: Int
    @NSManaged var propertyId: Int
    @NSManaged var position: Int
}