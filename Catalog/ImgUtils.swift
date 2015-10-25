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
    
    static let DENSITY = "1/"
    
    public static func getItemImgUrl(url:String) -> String
    {
        let DIR_IMG_UPL = "img/upload/"
        let DIR_IMG_CAMP = "item/"
       
        let ext = "_1.jpg"
        
        let photoUrl = Consts.URL_SITE + DIR_IMG_UPL + DIR_IMG_CAMP + DENSITY + url + ext
        return photoUrl
    }
    
    //Urls.URL_TITLE_LOGO + mImagesCatalog + logo + ".jpg"
    
    public static func getLogoImgUrl(logo:String) -> String
    {
        let photoUrl = Consts.URL_SITE + Consts.TITLE_LOGO_PARAM  + DENSITY + logo + ".jpg"
        return photoUrl
    }
}