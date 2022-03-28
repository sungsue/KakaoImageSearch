//
//  API.swift
//  BrandiProject
//
//  Created by 08liter on 2022/03/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class API: NSObject {
    static let shared = API()
    
    func getImage(query:String, page:Int, completionHandler: @escaping (AFDataResponse<Data?>) -> Void){
        let host = "https://dapi.kakao.com"
        let url = host + "/v2/search/image"
        let apiKey = "KakaoAK 78ac7742030fc8372defd11dc2f51d77"

        let param : Parameters = ["query":query ,"page":page, "size":30]
        
        
        AF.request(url, method:.get,
                   parameters: param,
                   encoding: URLEncoding.queryString,
                   headers: ["Authorization":apiKey],
                   interceptor: nil,
                   requestModifier: nil).response(completionHandler: completionHandler)
    }
    
}
