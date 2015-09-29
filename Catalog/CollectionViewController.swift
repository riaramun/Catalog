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
    
    var categoryId:Int?
    var delegate: CenterViewControllerDelegate?
    var context: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController? = nil
    var cellColor = true
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
    func getPhotoFor(itemId:Int) -> String? {
        
        let fetchRequest = NSFetchRequest(entityName: "Item_Photo")
        
        fetchRequest.predicate = NSPredicate(format: "%d == itemId", itemId)
        
        var photo:String?
        
        do {
            
            var res:Item_Photo?
            
            try res = self.context!.executeFetchRequest(fetchRequest).first as? Item_Photo
            
            photo = res?.photo
        }
        catch {
        }
        return photo
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
        fetchRequest.predicate = NSPredicate(format: "%d == " + column, id)
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
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
        cell.categoryLabel.text = item.shortName
        
        var attributes = self.dataHelper!.fetchGoodAttributesBy(item.itemId, categoryId:item.categoryId)
        
        let sortedKeys = Array(attributes.keys).sort(<)
        if sortedKeys.count > 0 {
            let key = sortedKeys[0]
            cell.priceTextView.text  = (attributes[key]?.name)! + String (": ") + (attributes[key]?.value)! + (attributes[key]?.dimen)!
        }
        if sortedKeys.count > 1 {
            let key = sortedKeys[1]
            cell.oldPriceTextView.text  = (attributes[key]?.name)! + String (": ") + (attributes[key]?.value)! + (attributes[key]?.dimen)!
        }
        if sortedKeys.count > 2 {
            let key = sortedKeys[2]
            cell.sizeTextView.text  = (attributes[key]?.name)! + String (": ") + (attributes[key]?.value)! + (attributes[key]?.dimen)!
        }
        
        
        
        
        
        var photoUrl = getPhotoFor(item.itemId)
        if photoUrl != nil {
            let URL_SITE = "http://rezmis3k.bget.ru/test3/catalog2/"
            let DIR_IMG_UPL = "img/upload/"
            let DIR_IMG_CAMP = "item/"
            let DENSITY = "1/"
            let ext = "_1.jpg"
            
            photoUrl = URL_SITE + DIR_IMG_UPL + DIR_IMG_CAMP + DENSITY + photoUrl! + ext
            
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
    
    @IBOutlet weak var priceTextView: UITextView!
    
    @IBOutlet weak var oldPriceTextView: UITextView!
    
    @IBOutlet weak var sizeTextView: UITextView!
    //@IBOutlet weak var categoryImgSmall: UIImageView!
    
    //@IBOutlet weak var categoryLabel: UILabel!
    
    //  func configureItem(item: Item)
    
    //  animalImageView.image = animal.image
    
    
    //imageCreatorLabel.text = animal.creator
    
    
}
