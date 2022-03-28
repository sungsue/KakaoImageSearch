//
//  Document.swift
//  BrandiProject
//
//  Created by 08liter on 2022/03/26.
//

import UIKit
import SwiftyJSON

class Document: NSObject {
//    "collection":string"news"
//    "thumbnail_url":string"https://search2.kakaocdn.net/argon/130x1 ..."
//    "image_url":string"http://t1.daumcdn.net/news/201706/21/ked ..."
//    "width":int540
//    "height":int457
//    "display_sitename":string"한국경제TV"
//    "doc_url":string"http://v.media.daum.net/v/20170621155930 ..."
//    "datetime":string"2017-06-21T15:59:30.000+09:00"
    
    var thumbnailUrl : String?
    var imageUrl : String?
    var displaySiteName : String?
    var dateTime : String?
    var width : Double?
    var height : Double?
    
    init(document:JSON) {
        thumbnailUrl = document["thumbnail_url"].string
        imageUrl = document["image_url"].string
        displaySiteName = document["display_sitename"].string
        dateTime = document["datetime"].string
        width = document["width"].double
        height = document["height"].double
    }
}
