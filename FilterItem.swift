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
public class FilterItem: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var param: String
    @NSManaged var propertyId: Int
    @NSManaged var property: Property
}