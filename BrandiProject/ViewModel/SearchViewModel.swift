//
//  SearchViewModel.swift
//  BrandiProject
//
//  Created by 08liter on 2022/03/26.
//

import UIKit
import SwiftyJSON

enum SearchResult {
    case Success
    case NoResult
    case InvalidQuery
    case UnHandledError
    case NetworkError
}

class SearchResultMeta{
    /**
     total_count    Integer    검색된 문서 수
     pageable_count    Integer    total_count 중 노출 가능 문서 수
     is_end    Boolean    현재 페이지가 마지막 페이지인지 여부, 값이 false면 page를 증가시켜 다음 페이지를 요청할 수 있음
     */
    var isEnd : Bool?
    var totalCount : Int?
    var pageableCount : Int?
    init(meta:JSON) {
        isEnd = meta["is_end"].bool
        totalCount = meta["total_count"].int
        pageableCount = meta["pageable_count"].int
    }
    
    /// 다음 페이지 요청 가능여부
    /// - Returns: 다음 페이지가 있을 경우 true
    func hasMoreData()->Bool{
        if let pageableCount = pageableCount, let isEnd = self.isEnd {
            return pageableCount > 0 && isEnd == false
        }
        return true
    }
    
    /// 검색 결과 여부
    /// - Returns: 있으면 true
    func isEmpty()->Bool{
        if let totalCount = pageableCount {
            return totalCount == 0
        }else{
            return false
        }
    }
}

class SearchViewModel: NSObject {
    var documents = [Document]()
    var searchMeta : SearchResultMeta?
    var page = 1
    var query = ""
    var nowLoading = false//NextPage 중복 호출 방지
}

extension SearchViewModel {
    func search(query:String,onComplete:(@escaping (_ result:SearchResult)->Void)){
        self.nowLoading = true
        
        if query != self.query {//마지막 쿼리와 다를 경우 검색 결과 초기화
            resetSearchResult()
        }
        
        self.query = query
        
        print("Query - Page \(self.page)")
        API.shared.getImage(query: self.query, page: page) { response in
            switch response.result {
            case .success(let result) :
                let json = JSON(result)
                print("Response : \(json.description)")
                self.searchMeta = json["meta"].dictionary != nil ? SearchResultMeta(meta: json["meta"]) : nil
                if self.searchMeta != nil {
                    self.searchMeta = SearchResultMeta(meta: json["meta"])
                    if self.searchMeta?.isEmpty() == true{
                        onComplete(.NoResult)
                    }else{
                        if let documents = json["documents"].array {
                            print("item count : \(documents.count)")
                            self.documents.append(contentsOf:documents.map{
                                Document(document: $0)
                            })
                            onComplete(.Success)
                        }
                    }
                }else if let errorType = json["errorType"].string, errorType == "MissingParameter"{
                    onComplete(.InvalidQuery)
                }else{
                    onComplete(.UnHandledError)
                }
            case .failure(let error) : onComplete(.NetworkError)
            }
            
            self.nowLoading = false
        }
    }
    
    func searchNextPage(onComplete:(@escaping (_ result:SearchResult)->Void)){
        if nowLoading == false && self.searchMeta?.hasMoreData() == true {
            page += 1
            search(query: query, onComplete: onComplete)
        }else if self.searchMeta?.hasMoreData() == false{
            print("NoMoreData")
        }
    }
    
    func resetSearchResult(){
        documents.removeAll()
        page = 1
    }
    
    func numberOfSearchResult()->Int{
        return documents.count
    }
}
