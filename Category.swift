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
    
    @NSManaged var category_id: Int
    @NSManaged var name: String
    @NSManaged var visibility: Int
    @NSManaged var photo: String
    @NSManaged var photo_edit_date: String
    
    @NSManaged var last_edit_date: String
    @NSManaged var parent: Int
    @NSManaged var position: Int
    @NSManaged var type: String
    @NSManaged var width: Int
    @NSManaged var height: Int
}