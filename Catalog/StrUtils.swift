//
//  StrUtils.swift
//  Catalog
//
//  Created by Admin on 09/10/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import UIKit

public class StrUtils {
    
    static func styleString(str:String, style:String, color:String) -> NSMutableAttributedString
    {
        var uiColor = UIColor.blackColor()
        if(!color.isEmpty) {
            uiColor = color.hexColor!
        }
        var strokeVal = 0
        if(style == "bs") {
            strokeVal = 1
        }
        let attributes: [String : AnyObject] = [NSStrikethroughStyleAttributeName : strokeVal, NSForegroundColorAttributeName : uiColor, NSStrikethroughColorAttributeName : UIColor.blackColor()]
        
        
        return NSMutableAttributedString(string: str, attributes: attributes) //1
        
    }
}