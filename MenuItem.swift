//
//  Category.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import CoreData

enum MenuItemType {
    case ECategories
    case EFavorites
    case ESearch
    case EHistory
    case ESettings
    case EContacts
}

class MenuItem: NSObject {

    init(type: MenuItemType) {
        self.type = type
        switch (type) {
        case .ECategories:
            self.name = "Categories".localized
        case .EFavorites:
            self.name = "Favorites".localized
        case .ESearch:
            self.name = "Search".localized
        case .EHistory:
            self.name = "History".localized
        case .ESettings:
            self.name = "Settings".localized
        case .EContacts:
            self.name = "Contacts".localized
        }
    }
    
    var type: MenuItemType
    var name: String = ""
}