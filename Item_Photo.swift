//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

@objc(Item_Photo)
class Item_Photo: NSManagedObject {
    
    @NSManaged var photoId: Int
    @NSManaged var itemId: Int
    @NSManaged var photo: String
    @NSManaged var uploadDate: String
    @NSManaged var position: Int

}