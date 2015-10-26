//
//  FavoritesViewController.swift
//  iOS8SwiftFavoritesViewControllerTutorial
//
//  Created by Arthur Knopper on 03/11/14.
//  Copyright (c) 2014 Arthur Knopper. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


public class FavoritesViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ToItemDetail" {
            
            var viewController:ItemDetailViewController
            
            if segue.destinationViewController is UINavigationController {
                let nav = segue.destinationViewController as! UINavigationController
                viewController = nav.topViewController as! ItemDetailViewController
            } else {
                viewController = segue.destinationViewController as! ItemDetailViewController
            }
            
            // let viewController = segue.destinationViewController as! ItemDetailViewController
            
            //   let nav = segue.destinationViewController as! UINavigationController
            // let viewController = nav.topViewController as! ItemDetailViewController
            
            viewController.context = self.context
            let item = sender as! Item
            viewController.item = item
        }
        else if segue.identifier == "ToFilterView" {
            var viewController:RightPanelViewController
            
            if segue.destinationViewController is UINavigationController {
                let nav = segue.destinationViewController as! UINavigationController
                viewController = nav.topViewController as! RightPanelViewController
            } else {
                viewController = segue.destinationViewController as! RightPanelViewController
            }
            
            viewController.context = self.context
            //let item = sender as! Item
            viewController.categoryId = categoryId!
            viewController.delegate = self
        }
        //viewController.viewNavigationItem.title = category.name
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?) {
        if (parent == nil) {
            
            // self.delegate!.setDrawerRightPanel(nil)
            self.delegate!.setDrawerLeftPanel(true)
        }
    }
    
    var categoryId:Int?
    var delegate: CenterViewControllerDelegate?
    
    var fetchedResultsController: NSFetchedResultsController? = nil
    var cellColor = true
    
    var context: NSManagedObjectContext?
    var dataHelper: DataHelper?
    
    
    struct GridView {
        struct CellIdentifiers {
            static let ItemCell = "ItemCell"
        }
    }
    
    @IBAction func setView2(sender: AnyObject) {
        
        // let item = ( sender as! UIBarButtonItem )
        
        if cellHeightToSet == 300 {
            cellHeightToSet = 600
            cellWidthToSet = collectionView!.bounds.size.width
        } else {
            cellHeightToSet = 300
            cellWidthToSet = collectionView!.bounds.size.width/2-5
        }
        
        self.collectionView!.reloadData()
    }
    
    
    
    func performFetch() {
        do {
            try fetchedResultsController!.performFetch()
            self.collectionView!.reloadData()
        } catch _ {
        }
    }
    
    func fetchResults( entityName:String, column:String) {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        // fetchRequest.predicate = NSPredicate(format: "%d == " + column + " and visible == 1", id)
        let primarySortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc.delegate = self
        fetchedResultsController = frc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.delegate!.setDrawerRightPanel(self)
        // self.delegate!.setDrawerLeftPanel(false)
        
        menuBarButton.image = UIImage(named: "menu.png")
        
        self.delegate!.setDrawerLeftPanel(true)
        
        self.dataHelper = DataHelper(context: self.context!)
        
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        fetchResults("Item", column: "categoryId")
        
        performFetch()
        
        cellHeightToSet = 300
        
        cellWidthToSet = collectionView!.bounds.size.width/2-5
        
        // Do any additional setup after loading the view.
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var retVal = 0;
        
        if let sections = fetchedResultsController!.sections {
            let currentSection = sections[section]
            retVal =  currentSection.numberOfObjects
        }
        
        return retVal
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GridView.CellIdentifiers.ItemCell, forIndexPath: indexPath) as! GridCell
        
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        let attributes = self.dataHelper!.fetchGoodAttributesBy(item.itemId, categoryId:item.categoryId)
        
        let strToSet = NSMutableAttributedString(string: item.shortName)
        strToSet.appendAttributedString(NSMutableAttributedString(string:"\r"))
        
        let sortedValues = attributes.values.sort({ (el1, el2) -> Bool in
            return el1.position < el2.position
        })
        var counter = 0
        for attribute in sortedValues {
            
            strToSet.appendAttributedString(NSMutableAttributedString(string: attribute.name + String (": ")))
            
            let styledStr = StrUtils.styleString( attribute.value + attribute.dimen, style: attribute.style, color: attribute.color)
            
            strToSet.appendAttributedString(styledStr)
            
            strToSet.appendAttributedString(NSMutableAttributedString(string:"\r"))
            counter++
            //if counter == 6 {break }
        }
        
        /*let sortedKeys = Array(attributes.keys).sort(<)
        var counter = 0
        
        for key in sortedKeys {
        
        strToSet.appendAttributedString(NSMutableAttributedString(string: (attributes[key]?.name)! + String (": ")))
        
        let styledStr = StrUtils.styleString( (attributes[key]?.value)! + (attributes[key]?.dimen)!, style: (attributes[key]?.style)!,color: (attributes[key]?.color)!)
        
        strToSet.appendAttributedString(styledStr)
        
        strToSet.appendAttributedString(NSMutableAttributedString(string:"\r"))
        counter++
        if counter == 6 {break }
        }*/
        
        cell.categoryLabel.attributedText = strToSet
        
        var photoUrl = dataHelper!.getPhotoFor(item.itemId)
        
        if photoUrl != nil {
            photoUrl = ImgUtils.getItemImgUrl(photoUrl!)
            if(photoUrl != nil) {
                Alamofire.request(.GET, photoUrl!).response { (request, response, data, error) in
                    NSLog(photoUrl!)
                    cell.categoryImgSmall.image = UIImage(data: data!, scale:1)
                }
            }
        }
        
        return cell
    }
    
    
    
    var cellWidthToSet:CGFloat = 0
    var cellHeightToSet:CGFloat = 0
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(cellWidthToSet, cellHeightToSet)
    }
    
    // MARK: UICollectionViewDelegate
    
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    public override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // for delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //   let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        //   self.performSegueWithIdentifier("ToItemDetail", sender: item)
    }
    
    @IBAction func mainMenuBtnTapped(sender: AnyObject) {
        
        delegate?.toggleLeftPanel()
        
    }
    
}

extension FavoritesViewController: RightPanelViewControllerDelegate {
    func filterItemsByParams() {
        
        self.dataHelper!.filterItemsByParams(self.categoryId!)
        
        fetchResults("Item", column: "categoryId")
        
        self.performFetch()
        
    }
    func collapseFilterPanel() {
        self.delegate?.toggleRightPanel()
    }
    func getCurrentCategoryId() -> Int {
        return self.categoryId!
    }
}
