import Foundation
import UIKit

//============================================================
// MARK: - AdvertiseEventNameDataSource
//============================================================

/// 광고 이벤트 정보 가져오는 데이터소스 - 주로 실제 화면의 뷰컨트롤러에서 구현
protocol AdvertiseEventNameDataSource {
    /// 광고의 이벤트 이름을 제공받음
    func getEventName(type: ADType, tableViewCell: UITableViewCell?) -> String
}

//============================================================
// MARK: - AdvertiseEventTrackerDataSource
//============================================================

/// 광고 추적을 위한 애널리틱스 이벤트 트래커를 제공받는 데이터소스 - 주로 베이스 뷰컨트롤러에서 구현
protocol AdvertiseEventTrackerDataSource: NSObject {
    func getTracker() -> AdvertiseAnalyticsTrackerDelegate
}

//============================================================
// MARK: - AdvertiseAnalyticsTracker
//============================================================

/// 광고 추적 트래커 델리게이트 - 실제 트래커에서 이 프로토콜을 구현함
protocol AdvertiseAnalyticsTrackerDelegate {
    func sendAdvertiseEvent(eventString: String)
}
