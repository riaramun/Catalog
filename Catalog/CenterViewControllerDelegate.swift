//
//  CenterViewControllerDelegate.swift
//  Catalog
//
//  Created by Admin on 27/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation

protocol CenterViewControllerDelegate {
    func setDrawerRightPanel(delegate:RightPanelViewControllerDelegate?)
    func setDrawerLeftPanel(enabled:Bool)
    func toggleLeftPanel()
    func toggleRightPanel()
}