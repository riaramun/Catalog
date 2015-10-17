//
//  CollectionViewController.swift
//  iOS8SwiftCollectionViewControllerTutorial
//
//  Created by Arthur Knopper on 03/11/14.
//  Copyright (c) 2014 Arthur Knopper. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var pickerView: AlertPickerView!
    let sort_menu_array = [
        "Цена (по возрастанию)",
        "Цена (по убыванию)",
        "Старая цена (по возрастанию)",
        "Старая цена (по убыванию)"]
    
    @IBAction func FilterTapped(sender: AnyObject) {
        //self.delegate!.toggleRightPanel()
    }
    
    
    @IBAction func showSortDialog(sender: AnyObject) {
        self.pickerView.showPicker()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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
        }
        //viewController.viewNavigationItem.title = category.name
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
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
        cellHeightToSet = 600
        cellWidthToSet = collectionView!.bounds.size.width
        self.collectionView!.reloadData()
    }
    
    @IBAction func setView1(sender: AnyObject) {
        cellWidthToSet = collectionView!.bounds.size.width/2-5
        cellHeightToSet = 300
        self.collectionView!.reloadData()
    }
    
    
    func performFetch() {
        do {
            try fetchedResultsController!.performFetch()
            self.collectionView!.reloadData()
        } catch _ {
        }
    }
    
    func fetchResults(id:Int, entityName:String, column:String) {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%d == " + column + " and position >= 0", id)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView = AlertPickerView()
        self.pickerView.items = sort_menu_array
        self.pickerView.delegate = self
        
        //self.delegate!.setDrawerRightPanel(self)
        self.delegate!.setDrawerLeftPanel(false)
        
        self.view.addSubview(pickerView)
        
        self.dataHelper = DataHelper(context: self.context!)
        
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        fetchResults(self.categoryId!, entityName: "Item", column: "categoryId")
        
        performFetch()
        
        cellHeightToSet = 300
        
        cellWidthToSet = collectionView!.bounds.size.width/2-5
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var retVal = 0;
        
        if let sections = fetchedResultsController!.sections {
            let currentSection = sections[section]
            retVal =  currentSection.numberOfObjects
        }
        
        return retVal
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GridView.CellIdentifiers.ItemCell, forIndexPath: indexPath) as! GridCell
        
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        var attributes = self.dataHelper!.fetchGoodAttributesBy(item.itemId, categoryId:item.categoryId)
        
        let strToSet = NSMutableAttributedString(string: item.shortName)
        strToSet.appendAttributedString(NSMutableAttributedString(string:"\r"))
        let sortedKeys = Array(attributes.keys).sort(<)
        var counter = 0
        for key in sortedKeys {
            
            strToSet.appendAttributedString(NSMutableAttributedString(string: (attributes[key]?.name)! + String (": ")))
            
            let styledStr = StrUtils.styleString( (attributes[key]?.value)! + (attributes[key]?.dimen)!, style: (attributes[key]?.style)!,color: (attributes[key]?.color)!)
            
            strToSet.appendAttributedString(styledStr)
            
            strToSet.appendAttributedString(NSMutableAttributedString(string:"\r"))
            counter++
            if counter == 4 {break }
        }
        
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
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // for delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    internal override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let item = fetchedResultsController!.objectAtIndexPath(indexPath) as! Item
        
        self.performSegueWithIdentifier("ToItemDetail", sender: item)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}

class GridCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImgSmall: UIImageView!
    
    @IBOutlet weak var categoryLabel: UITextView!
    
    /* @IBOutlet weak var priceTextView: UITextView!
    
    @IBOutlet weak var oldPriceTextView: UITextView!
    
    @IBOutlet weak var sizeTextView: UITextView!*/
    
}
extension CollectionViewController: AlertPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerView.items.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerView.items[row]
    }
    func pickerView(pickerView: UIPickerView, didSelect numbers: [Int]) {
        
        let selected = numbers[0]
        switch(selected) {
        case 0:
            self.dataHelper?.sortItemsByCurrentPrice(self.categoryId!, increase: true, currentPrice:true)
            performFetch()
            break
        case 1:
            self.dataHelper?.sortItemsByCurrentPrice(self.categoryId!, increase: false, currentPrice:true)
            performFetch()
            break
        case 2:
            self.dataHelper?.sortItemsByCurrentPrice(self.categoryId!, increase: true, currentPrice:false)
            performFetch()
            break
        case 3:
            self.dataHelper?.sortItemsByCurrentPrice(self.categoryId!, increase: false, currentPrice:false)
            performFetch()
            break
        default:
            break
        }
        print("selected \(numbers)")
        
    }
    
    func pickerViewDidHide(pickerView: UIPickerView) {
        print("hided pickerview")
    }
}
extension CollectionViewController: RightPanelViewControllerDelegate {
    func updateView() {
        self.dataHelper!.resetfilter()
        self.dataHelper!.filterItemsByParams(self.categoryId!)
        fetchResults(self.categoryId!, entityName: "Item", column: "categoryId")
        self.performFetch()
    }
    func collapseFilterPanel() {
        self.delegate?.toggleRightPanel()
    }
    func getCurrentCategoryId() -> Int {
        return self.categoryId!
    }
}

extension String {
    var hexColor: UIColor? {
        let hex = self.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        guard NSScanner(string: hex).scanHexInt(&int) else {
            return nil
        }
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
