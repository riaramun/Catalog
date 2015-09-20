//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

class MenuItem: NSObject {

    init(name: String) {
        self.name = name
    }
    
    var name: String = ""
}