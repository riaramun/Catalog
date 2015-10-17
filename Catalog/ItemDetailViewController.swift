//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import CoreData
import DOCheckboxControl
import Alamofire

class ItemDetailViewController: UIViewController {
    
    @IBAction func onBackTapped(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }else{
        
        }
    }
    var context: NSManagedObjectContext?
    var dataHelper: DataHelper?
    var item: Item?
    
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBOutlet weak var descrTextView: UITextView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataHelper = DataHelper(context: self.context!)
        setDescription(self.item!)
        
        var photoUrl = dataHelper!.getPhotoFor(item!.itemId)
        
        if photoUrl != nil {
            photoUrl = ImgUtils.getItemImgUrl(photoUrl!)
            if(photoUrl != nil) {
                Alamofire.request(.GET, photoUrl!).response { (request, response, data, error) in
                    NSLog(photoUrl!)
                    self.mainImage.image = UIImage(data: data!, scale:1)
                }
            }
        }
        
    }
    
    func setDescription(item:Item) {
        
        var attributes = self.dataHelper!.fetchGoodAttributesBy(item.itemId, categoryId:item.categoryId)
        
        let strToSet = NSMutableAttributedString(string: item.shortName)
        strToSet.appendAttributedString(NSMutableAttributedString(string:"\r"))
        let sortedKeys = Array(attributes.keys).sort(<)
        
        for key in sortedKeys {
            
            strToSet.appendAttributedString(NSMutableAttributedString(string: (attributes[key]?.name)! + String (": ")))
            
            let styledStr = StrUtils.styleString( (attributes[key]?.value)! + (attributes[key]?.dimen)!, style: (attributes[key]?.style)!,color: (attributes[key]?.color)!)
            
            strToSet.appendAttributedString(styledStr)
            
            strToSet.appendAttributedString(NSMutableAttributedString(string:"\r"))
        }
        descrTextView.attributedText = strToSet
    }
}

