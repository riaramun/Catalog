//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

@objc(Property_List_Value)
class Property_List_Value: NSManagedObject {
    
    @NSManaged var listId: Int
    @NSManaged var propertyId: Int
    @NSManaged var position: Int
    @NSManaged var value: String
    
}