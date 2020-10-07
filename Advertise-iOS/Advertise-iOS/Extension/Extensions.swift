//
//  UIView.swift
//  Advertise-iOS
//
//  Created by UramMyeongbu on 2020/10/07.
//

import UIKit
import RxSwift
import RxCocoa

extension UIView {
    /// 뷰가 화면에 보여진 상태인지 여부
    var isVisibleToUser: Bool {

        if isHidden || alpha == 0 || superview == nil {
            return false
        }

        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return false
        }

        let viewFrame = convert(bounds, to: rootViewController.view)

        let topSafeArea: CGFloat
        let bottomSafeArea: CGFloat

        if #available(iOS 11.0, *) {
            topSafeArea = rootViewController.view.safeAreaInsets.top
            bottomSafeArea = rootViewController.view.safeAreaInsets.bottom
        } else {
            topSafeArea = rootViewController.topLayoutGuide.length
            bottomSafeArea = rootViewController.bottomLayoutGuide.length
        }

        return viewFrame.minX >= 0 &&
            viewFrame.maxX <= rootViewController.view.bounds.width &&
            viewFrame.minY >= topSafeArea - 20 &&
            viewFrame.maxY <= rootViewController.view.bounds.height - bottomSafeArea

    }
}

/// 스트링에서 공백, 줄바꿈을 모두 _로 변경
extension String {
    func replaceWhiteSpace() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter{!$0.isEmpty}
            .joined(separator: "_")
    }
}

/// 스크롤이 끝났을 때 이벤트 발생
extension Reactive where Base: UIScrollView {
    public var didEndScrolling: ControlEvent<Bool> {
        let source = Observable
            .merge(base.rx.didEndDragging.map{!$0},
                   base.rx.didEndScrollingAnimation.map{true},
                   base.rx.didEndDecelerating.map{true})
            .filter{$0}
            
        return ControlEvent(events: source)
    }
}
