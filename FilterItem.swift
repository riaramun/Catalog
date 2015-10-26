//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData
@objc(FilterItem)
class FilterItem: NSManagedObject {
   // @NSManaged var name: String
    @NSManaged var position: Int
    @NSManaged var listId: Int
    @NSManaged var param: String
    @NSManaged var paramInt: Int
    @NSManaged var selected: Bool
    @NSManaged var propertyId: Int
    @NSManaged var property: Property
}