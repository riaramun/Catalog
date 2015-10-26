//
//  LoadingViewController.swift
//  Catalog
//
//  Created by Admin on 25.10.15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import UIKit
import CoreData
import DOCheckboxControl
import Alamofire

public class LoadingViewController: UIViewController , UINavigationControllerDelegate{
    
    var dataHelper:DataHelper?
    
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var deleteData: UIButton!
    @IBOutlet weak var tryAgain: UIButton!
    @IBOutlet weak var processState: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var backNavigationItem: UINavigationItem!
    
    @IBAction func deleteBaseAction(sender: AnyObject) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("", forKey: "date_update")
        userDefaults.synchronize()

        
        DataHelper.dataStack.drop()
        dataHelper?.delegate?.dataUpdated(false)
        tryAgain.hidden = true
        self.activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        
        let delay = 2.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue()) {
            
            self.deleteData.hidden = false
            self.tryAgain.hidden = false
            self.activityIndicator.hidden = true
            
            let data = self.dataHelper?.fetchAllItems()
            
            if data == nil || data?.count == 0 {
                self.navigationItem.setHidesBackButton(true, animated:true)
            }
        }
        
    }
    
    @IBAction func tryAgainAction(sender: AnyObject) {
        
        dataHelper?.getSettings()
        
        tryAgain.hidden = true
        deleteData.hidden = true
        
        self.activityIndicator.hidden = false
        
        activityIndicator.startAnimating()
        
        self.updateViewConstraints()
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var navController: UINavigationController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        deleteData.hidden = true
        tryAgain.hidden = true
        navigationController?.delegate = self
        
        navController = self.navigationController
        
        self.activityIndicator.startAnimating()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let title_image = userDefaults.valueForKey("logo")  {
            
            let imgUrl = ImgUtils.getLogoImgUrl(title_image as! String)
            
            Alamofire.request(.GET, imgUrl).response { (request, response, data, error) in
                self.logoImg.image = UIImage(data: data!, scale:1)
            }
        }
    }
    func skipUpdate (date:String) {
        processState.text = "Обновлено от " + date
        processState.updateConstraints()
        deleteData.hidden = false
        self.navigationItem.setHidesBackButton(false, animated:true)
        tryAgain.hidden = false
        self.activityIndicator.hidden = true
    }
    func showResult(success:Bool) {
        
        self.activityIndicator.hidden = true
        
        if success {
            processState.text = "База данных усешно обновлена!"
            self.navigationItem.setHidesBackButton(false, animated:true)
        }
        else {
            processState.text = "Ошибка обновления базы данных"
            tryAgain.hidden = false
        }
        processState.updateConstraints()
        
        deleteData.hidden = false
        
        let data = self.dataHelper?.fetchAllItems()
        
        if data == nil || data?.count == 0 {
            
            self.navigationItem.setHidesBackButton(true, animated:true)
        }
        
        
    }
    
}