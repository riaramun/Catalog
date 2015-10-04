//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit

protocol LeftPanelViewControllerDelegate {
    func menuItemSelected(menuItem: MenuItem)
}
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}
class LeftPanelViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: LeftPanelViewControllerDelegate?
    
    
    
    
    func menuItems() -> Array<MenuItem> {
        return [    MenuItem(type: MenuItemType.ECategories),
            MenuItem(type: MenuItemType.EFavorites),
            MenuItem(type: MenuItemType.ESearch),
            MenuItem(type: MenuItemType.ESettings),
            MenuItem(type: MenuItemType.EHistory),
            MenuItem(type: MenuItemType.EContacts)]
    }
    
    struct TableView {
        struct CellIdentifiers {
            static let MenuItemCell = "MenuItemCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }
    
}

// MARK: Table View Data Source

extension LeftPanelViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.MenuItemCell, forIndexPath: indexPath) as! MenuItemCell
        cell.configureForMenuItem(menuItems()[indexPath.row])
        return cell
    }
}

// Mark: Table View Delegate

extension LeftPanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMenuItem = menuItems()[indexPath.row]
        delegate?.menuItemSelected(selectedMenuItem)
    }
    
}

class MenuItemCell: UITableViewCell {
    
    @IBOutlet weak var MenuItemImageView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    // @IBOutlet weak var imageCreatorLabel: UILabel!
    
    func configureForMenuItem(menuItem: MenuItem) {
        //  MenuItemImageView.image = MenuItem.image
        imageNameLabel.text = menuItem.name
        //imageCreatorLabel.text = MenuItem.creator
    }
    
}