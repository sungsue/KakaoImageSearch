//
//  ViewController.swift
//  BrandiProject
//
//  Created by 08liter on 2022/03/26.
//

import UIKit
import SwiftyJSON
import Kingfisher
import Toaster

class SearchNextFooter : UICollectionReusableView {
    
}

class SearchResultCell : UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    
}

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var searchViewModel = SearchViewModel()
    var searchTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
}

extension ViewController {
    
    func initViews(){
        searchBar.delegate = self
        searchBar.placeholder = "검색어를 입력해 주세요."
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SearchNextFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SearchNextFooter")
    }
    
    /// 컬렉션뷰 업데이트
    func updateResult(){
        self.collectionView.reloadData()
    }
    
    /// 메시지 표시
    func showMessage(text:String){
        Toast(text:text, delay: 0, duration: 2).show()
    }
    
    /// 검색 결과 처리
    /// - Parameter searchResult: 검색 결과
    func handleResult(searchResult:SearchResult){
        switch searchResult {
        case .Success:
            self.updateResult()
        case .NoResult:
            showMessage(text: "검색 결과가 없습니다.")
            self.updateResult()
        case .InvalidQuery://쿼리 파라미터 에러 - 별도 메시지 표시 없이 목록 초기화
            self.updateResult()
        case .UnHandledError://
            showMessage(text: "검색중 오류가 발생했습니다(\(searchResult)")
            self.updateResult()
        case .NetworkError:
            showMessage(text: "검색중 네트워크 오류가 발생했습니다(\(searchResult)")
            self.updateResult()
        }
    }
    
    
    /// 이미지 검색 요청
    @objc func searchImage(){
        if let query = self.searchBar.text, query.trimmingCharacters(in: CharacterSet.whitespaces).count > 0{
            searchViewModel.search(query: query) { result in
                self.handleResult(searchResult: result)
            }
        }
    }
    
    //MARK: UISeachBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         if let timer = self.searchTimer {//생성된 타이머가 있을 경우 취소
            print("cancel scheduled search")
            timer.invalidate()
            self.searchTimer = nil
        }
        //1초 인터벌 후 실행되는 타이머 생성
        searchTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(searchImage), userInfo: nil, repeats: false)
    }
    
    //MARK: CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = searchViewModel.documents[indexPath.row]
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageViewerViewController") as! ImageViewerViewController
        vc.viewModel = ImageViewerViewModel.init(doc: item)
        
        self.present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 20)/3
        return CGSize.init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.numberOfSearchResult()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SearchResultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        
        let item = searchViewModel.documents[indexPath.row]
        if let thumbnailUrl = item.thumbnailUrl {
            cell.imageView.kf.setImage(with: URL.init(string: thumbnailUrl))
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let meta = searchViewModel.searchMeta {
            //마지막 페이지일 경우 footer 숨김
            return CGSize.init(width: collectionView.frame.size.width, height:meta.hasMoreData() ? 50 : 0)
        }else{
            return CGSize.init(width: collectionView.frame.size.width, height:50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {//Footer 표시할 경우 다음 페이지 요청
        searchViewModel.searchNextPage { result in
            self.handleResult(searchResult: result)
        }
        let footerview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchNextFooter", for: indexPath)
        return footerview
    }
}

