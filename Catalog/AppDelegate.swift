//
//  AppDelegate.swift
//  Catalog
//
//  Created by Admin on 15/09/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import UIKit
import DATAStack
import MMDrawerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let dataStack = DATAStack(modelName: "Catalog")
    
    var centerContainer: MMDrawerController?
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let leftViewController = UIStoryboard.leftViewController()
        
        leftViewController!.delegate = self
        
        let categoryViewController = UIStoryboard.categoryViewController()
        
        categoryViewController!.context = self.dataStack.mainContext
        
        categoryViewController!.delegate = self
        
        
        // let rigthViewController = UIStoryboard.rightViewController()
        //rigthViewController!.context = self.dataStack.mainContext
        
        let leftSideNav = UINavigationController(rootViewController: UIStoryboard.leftViewController()!)
        let centerNav = UINavigationController(rootViewController: categoryViewController!)
        // let rightNav = UINavigationController(rootViewController: rigthViewController!)
        
        centerContainer = MyDrawerController(centerViewController: centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:nil)
        
        
        centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView;
        
        centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView;
        
        window!.rootViewController = centerContainer
        
        window!.makeKeyAndVisible()
        
        
        if let context = self.dataStack.mainContext {
            let dataHelper = DataHelper(context: context)
            dataHelper.seedDataStore()
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
}
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> LeftPanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? LeftPanelViewController
    }
    
    class func rightViewController() -> RightPanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RightPanelViewController") as? RightPanelViewController
    }
    
    class func categoryViewController() -> CategoryViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CategoryViewController") as? CategoryViewController
    }
}

extension AppDelegate: CenterViewControllerDelegate {
    
    func setDrawerRightPanel(delegate:RightPanelViewControllerDelegate?) {
        
        if( delegate != nil) {
            
            let rightViewController = UIStoryboard.rightViewController()!
            
            let rightSideNav = UINavigationController(rootViewController: rightViewController)
            
            rightViewController.delegate = delegate!
            rightViewController.context = self.dataStack.mainContext
            (window!.rootViewController as! MMDrawerController).rightDrawerViewController = rightSideNav
            
        } else {
            
            (window!.rootViewController as! MMDrawerController).rightDrawerViewController = nil
        }
    }
    func setDrawerLeftPanel(enabled:Bool) {
        
        let leftSideNav = UINavigationController(rootViewController: UIStoryboard.leftViewController()!)
        
        (window!.rootViewController as! MMDrawerController).leftDrawerViewController = enabled ? leftSideNav : nil
    }
    
    func toggleLeftPanel() {
        (window!.rootViewController as! MMDrawerController).toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    func toggleRightPanel() {
        (window!.rootViewController as! MMDrawerController).toggleDrawerSide(MMDrawerSide.Right, animated: true, completion: nil)
    }
}

extension AppDelegate: LeftPanelViewControllerDelegate {
    func menuItemSelected(menuItem: MenuItem) {
        
    }
}
class MyDrawerController:MMDrawerController{
    

}
