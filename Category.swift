//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

@objc(Category)
class Category: NSManagedObject {
    
    @NSManaged var categoryId: Int
    @NSManaged var name: String
    @NSManaged var visibility: Int
    @NSManaged var photo: String
    @NSManaged var photoEditDate: String
    
    @NSManaged var lastEditDate: String
    @NSManaged var parent: Int
    @NSManaged var position: Int
    @NSManaged var categoryType: String
    @NSManaged var width: Int
    @NSManaged var height: Int
}