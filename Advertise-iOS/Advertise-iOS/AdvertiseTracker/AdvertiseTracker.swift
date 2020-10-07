import Foundation
import RxSwift
import RxCocoa

class AdvertiseTracker {

    /// 이벤트 명 받아올 데이터소스
    var eventNameDataSource: AdvertiseEventNameDataSource?
    /// FA이벤트 트래커 받아올 데이터소스
    weak var FAEventTrackerDataSource: AdvertiseEventTrackerDataSource?
    
    /// 페이지 이벤트 기록용 Set, 페이지 변경 시 초기화
    private var pageEventSet = Set<String>()
    
    /// 테이블뷰가 갱신되어 재구독이 필요한 상황일 경우 true
    private var tableViewRefreshed = true
    
    /// 자식 뷰의 옵저버블을 관리할 Disposebag
    private var childDisposeBag: DisposeBag = DisposeBag()
    
    func deinitialize() {
        self.eventNameDataSource = nil
        self.FAEventTrackerDataSource = nil
        self.pageEventSet.removeAll()
        self.childDisposeBag = DisposeBag()
    }
    
    
    //============================================================
    // MARK: - Tracking Method
    //============================================================
    
    
    /// 테이블 뷰 안에 광고 셀이 있는 경우 추적하는 메소드
    /// - Parameters:
    ///   - viewController: 생명주기에 맞춰 이벤트 수신을 위한 뷰컨트롤러
    ///   - adType: 광고 타입 ADType
    ///   - scrollTarget: 테이블뷰
    ///   - targetClass: 광고를 담고있는 셀
    func addAdvertiseTracking<T : UITableViewCell> (viewController: UIViewController, adType: ADType, scrollTarget: UITableView, targetClass: T.Type) -> Disposable {
        
        var observableArray: [Observable<Bool>] = []
        observableArray.append(scrollTarget.rx
                                .didEndScrolling
                                .asObservable())
        observableArray.append(viewController.rx
                                .methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
                                .map{_ in true})
        observableArray.append(scrollTarget.rx
                                .didEndDisplayingCell
                                .filter{_ in self.tableViewRefreshed}
                                .map{_ in self.tableViewRefreshed = false}
                                .map{_ in true})
        
        return Observable.from(observableArray)
            .merge()
            .flatMap{_ in self.getTargetView(parent: scrollTarget, classType: T.self)}
            .filter{$0.isVisibleToUser}
            .subscribe(onNext: { [weak self] cell in
                if let eventNameDataSource = self?.eventNameDataSource {
                    let eventName = eventNameDataSource.getEventName(type: adType, tableViewCell: cell)
                    self?.sendViewEvent(adType: adType, eventName: eventName)
                }
            })
    }
    
    /// 스크롤 안에 스크롤 형식으로 배너가 존재하는 경우 트래킹할 메소드 (세로 스크롤 부모 안에 가로 스크롤 되는 광고)
    /// - Parameters:
    ///   - viewController: ViewController, 생명주기에 맞춰 Subscribe를 조절하기 위해 필요
    ///   - adType: 광고 타입, ADType
    ///   - scrollTarget: 스크롤 대상인 부모 테이블 뷰
    ///   - childScrollCellClass: 스크롤되는 배너를 가지고 있는 내부 테이블 뷰 셀
    func addAdvertiseTrackingScrollInScroll<T : UITableViewCell> (viewController: UIViewController, adType: ADType, scrollTarget: UITableView, childScrollCellClass: T.Type) -> Disposable {
        
        /// 내부 테이블뷰 셀의 스크롤을 기록할 서브젝트
        let scrollSubject: PublishSubject = PublishSubject<Bool>.init()
        /// 뷰컨트롤러의 생명주기를 기록할 서브젝트
        let viewControllerSubject: PublishSubject = PublishSubject<Bool>.init()
        /// 셀 내부의 스크롤뷰에 중복해서 이벤트 구독하지 않도록 구분하기 위한 셋
        var childScrollSet = Set<UIScrollView>()
        
        /// 기본 이벤트 발생 옵저버블 - 스크롤이 끝난 경우, 테이블뷰 갱신 시 최초 1회
        var observableArray: [Observable<Bool>] = []
        observableArray.append(scrollTarget.rx
                                .didEndScrolling
                                .asObservable())
        observableArray.append(scrollTarget.rx
                                .didEndDisplayingCell
                                .filter{_ in self.tableViewRefreshed}
                                .map{_ in self.tableViewRefreshed = false}
                                .map{_ in true})
        
        /// 뷰컨트롤러 생명주기 상태에 따라 서브젝트에 발행
        viewController.rx
            .methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
            .subscribe(onNext: {_ in viewControllerSubject.onNext(true)})
            .disposed(by: childDisposeBag)
        viewController.rx
            .methodInvoked(#selector(UIViewController.viewDidDisappear(_:)))
            .subscribe(onNext: {_ in viewControllerSubject.onNext(false)})
            .disposed(by: childDisposeBag)
        
        /// 부모 테이블뷰가 스크롤 발생되면 그려진 테이블 셀을 추적하여 그 안의 스크롤뷰에 이벤트 리스너를 설정, 구독하여 모니터링
        let scrollObservable = Observable.from(observableArray).merge()
                .flatMap{_ in self.getTargetView(parent: scrollTarget, classType: T.self)}
                .map{ cell -> Bool in
                    let childArray = ChildViewFinder<UIScrollView>().findChildView(parent: cell)
                    for childScrollView in childArray {
                        if !childScrollSet.contains(childScrollView) {
                            childScrollSet.insert(childScrollView)
                            /// 스크롤 종료 시 true 발행
                            childScrollView.rx.didEndScrolling
                                .subscribe(onNext: {_ in
                                    scrollSubject.onNext(true)
                                }).disposed(by: self.childDisposeBag)
                            
                            /// 스크롤 발생 시 false 발행
                            childScrollView.rx.didScroll
                                .throttle(.milliseconds(300), latest: true, scheduler: MainScheduler.instance)
                                .subscribe(onNext: {_ in
                                    scrollSubject.onNext(false)
                                }).disposed(by: self.childDisposeBag)
                        }
                    }
                    scrollSubject.onNext(true)
                    return true
                }
        
        /// 기본 옵저버블과 자식 스크롤 상태, 뷰컨트롤러 생명주기 상태가 모두 OK된 경우에만 이벤트 구독
        return Observable
            .combineLatest(scrollObservable, scrollSubject, viewControllerSubject, resultSelector: {$0 && $1 && $2})
            .filter{$0}
            .flatMap{_ in self.getTargetView(parent: scrollTarget, classType: T.self)}
            .filter{$0.isVisibleToUser}
            .subscribe(onNext: { [weak self] cell in
                if let eventNameDataSource = self?.eventNameDataSource {
                    let eventName = eventNameDataSource.getEventName(type: adType, tableViewCell: cell)
                    self?.sendViewEvent(adType: adType, eventName: eventName)
                }
            })
    }
    
    /// 페이지뷰 이벤트 기록을 클리어하는 메소드 ( 부모뷰는 남아있는 채로 데이터가 갱신되어 자식뷰가 교체되는 경우 )
    func clearPageEventCount() {
        pageEventSet.removeAll()
        self.tableViewRefreshed = true
    }
 
    
    /// 뷰 이벤트 전송
    /// - Parameters:
    ///   - adType: 광고 타입
    ///   - eventName: 광고에서 쓰이는 제목 스트링
    func sendViewEvent(adType: ADType, eventName: String?) {
        guard let eventName = eventName, !eventName.isEmpty else { return }
        
        let pvEventString = adType.getEventString(eventName: eventName, isSession: false)
        if !pageEventSet.contains(pvEventString) {
            pageEventSet.insert(pvEventString)
            self.FAEventTrackerDataSource?.getTracker().sendAdvertiseEvent(eventString: pvEventString)
        }
    }
    
    
    /// 클릭 이벤트 전송
    /// - Parameters:
    ///   - adType: 광고 타입
    ///   - eventName: 광고에서 쓰이는 제목 스트링
    func sendClickEvent(adType: ADType, eventName: String?) {
        guard let eventName = eventName, !eventName.isEmpty else { return }
        
        let pcEventString = adType.getEventString(eventName: eventName, isSession: false, isClick: true)
        if !pageEventSet.contains(pcEventString) {
            pageEventSet.insert(pcEventString)
            self.FAEventTrackerDataSource?.getTracker().sendAdvertiseEvent(eventString: pcEventString)
        }
    }
    
    //============================================================
    // MARK: - Finder Method
    //============================================================
    
    /// 자식 뷰 중에서 특정 뷰를 찾는 메소드
    /// - Parameters:
    ///   - parent: 부모 뷰
    ///   - classType: 찾을 클래스 타입
    private func getTargetView<T : UIView>(parent: UIScrollView, classType: T.Type) -> Observable<T> {
        let childArray = ChildViewFinder<T>().findChildView(parent: parent)
        return Observable.from(childArray)
    }
    
    /// 자식 전체에서 특정 클래스의 View 를 찾아주는 파인더 클래스
    private class ChildViewFinder<T : UIView> {

        func findChildView(parent: UIView) -> [T] {
            var viewArray: [T] = []
            
            for childView in parent.subviews {
                if let childView = childView as? T {
                    viewArray.append(childView)
                }
                if childView.subviews.count > 0 {
                    viewArray.append(contentsOf: findChildView(parent: childView))
                }
            }
        
            return viewArray;
        }
    }
}
