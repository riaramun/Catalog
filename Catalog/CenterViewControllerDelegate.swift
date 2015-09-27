//
//  CenterViewControllerDelegate.swift
//  Catalog
//
//  Created by Admin on 27/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
  //  optional func categorySelected(category: Category)
}