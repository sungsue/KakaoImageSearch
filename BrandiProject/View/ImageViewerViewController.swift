//
//  ImageViewerViewController.swift
//  BrandiProject
//
//  Created by 08liter on 2022/03/27.
//

import UIKit
import Kingfisher
import Toaster

class ImageViewerViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var viewModel : ImageViewerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImageViewerViewController {
    func initViews(){
        setupImage()
        setupImageInfo()
    }
    
    func setupImage(){
        if let imageUrl = viewModel?.document.imageUrl {
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: URL.init(string: imageUrl)){ result in
                switch result {
                case .success(_):
                    self.setupImageInfo()
                case .failure(let error):
                    print("download failed : \(error.localizedDescription)")
                    Toast.init(text: "이미지를 불러오는데 실패했습니다.", delay: 0, duration: 3).show()
                }
            }
            
            let imageHeight = viewModel?.document.height
            let imageWidth = viewModel?.document.width
            let scaledHeight = (imageHeight! * self.view.frame.size.width)/imageWidth!
            
            if scaledHeight > self.view.frame.size.height {//이미지 비율이 화면 비율보다 클 경우 스크롤
                self.imageContainer.addConstraint(NSLayoutConstraint.init(item: self.imageContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: scaledHeight))
            }else{//화면 비율보다 작을 경우 중앙정렬
                self.scrollView.addConstraint(NSLayoutConstraint.init(item: self.scrollView, attribute: .centerY, relatedBy: .equal, toItem: self.imageContainer, attribute: .centerY, multiplier: 1, constant: 0))
            }
        }
    }
    
    /// 이미지 메타 데이터 표시
    func setupImageInfo(){
        if let site = viewModel?.document.displaySiteName {
            self.siteNameLabel.text = site
        }
        
        if let date = viewModel?.document.dateTime {
            self.dateLabel.text = date
        }
    }
    
}
