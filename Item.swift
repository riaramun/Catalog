//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject {
    
    @NSManaged var itemId: Int
    @NSManaged var categoryId: Int
    @NSManaged var position: Int
    @NSManaged var shortName: String
    @NSManaged var longName: String
    @NSManaged var code: String
    @NSManaged var shortDescr: String
    @NSManaged var longDescr: String

    }