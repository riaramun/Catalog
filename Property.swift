//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData
@objc(Property)
public class Property: NSManagedObject {
    @NSManaged var typeId: Int
    @NSManaged var propertyId: Int
    @NSManaged var dimension: String
    @NSManaged var name: String
    @NSManaged var color: String
    @NSManaged var style: String
    @NSManaged var filterItems: NSSet
}