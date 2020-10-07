//
//  ViewController.swift
//  Advertise-iOS
//
//  Created by UramMyeongbu on 2020/10/07.
//

import UIKit

class MainViewController: BaseViewController, AdvertiseEventNameDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        advertiseTracker.eventNameDataSource = self
        
        // 상하스크롤 내(테이블 뷰)안에 좌우스크롤 되는 메인배너 추적 (DUMMY)
        advertiseTracker
            .addAdvertiseTrackingScrollInScroll(viewController: self, adType: .HomeBigBanner, scrollTarget: self.tableView, childScrollCellClass: HomeMainBannerCell.self)
            .disposed(by: disposeBag)
        
        // 단순 상하스크롤 안(테이블 뷰)의 배너 추적 (DUMMY)
        advertiseTracker
            .addAdvertiseTracking(viewController: self, adType: .HomeSmallBanner, scrollTarget: self.tableView, targetClass: HomeSmallBannerCell.self)
            .disposed(by: disposeBag)
    }

    func getEventName(type: ADType, tableViewCell: UITableViewCell?) -> String {
        if let tableViewCell = tableViewCell as? HomeMainBannerCell {
            if let title = tableViewCell.advertiseTitle {
                return title
            }
        }
        else if let tableViewCell = tableViewCell as? HomeSmallBannerCell {
            return tableViewCell.advertiseID
        }
        
        return "Unknown"
    }

    
}

// DUMMY CELL
class HomeMainBannerCell: UITableViewCell {
    var advertiseTitle: String?
}

class HomeSmallBannerCell: UITableViewCell {
    var advertiseID: String = "101"
}
