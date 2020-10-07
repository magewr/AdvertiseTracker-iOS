import Foundation
import UIKit
import RxSwift

class BaseViewController: UIViewController, AdvertiseEventTrackerDataSource {
    
    // 이벤트 트래커(앰플리튜드, 앱스플라이어, FA 등등등)
    let eventTracker = DummyEventTracker()
    
    let advertiseTracker = AdvertiseTracker()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    func getTracker() -> AdvertiseAnalyticsTrackerDelegate {
        return eventTracker
    }
    
}
