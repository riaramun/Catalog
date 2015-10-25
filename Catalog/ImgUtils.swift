//
//  StrUtils.swift
//  Catalog
//
//  Created by Admin on 09/10/15.
//  Copyright © 2015 lebrom. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

public class ImgUtils {
    
    public static func getItemImgUrl(url:String) -> String
    {
        let DIR_IMG_UPL = "img/upload/"
        let DIR_IMG_CAMP = "item/"
        let DENSITY = "1/"
        let ext = "_1.jpg"
        
        let photoUrl = Consts.URL_SITE + DIR_IMG_UPL + DIR_IMG_CAMP + DENSITY + url + ext
        return photoUrl
    }
}