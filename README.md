# AdvertiseTracker-iOS

앱 내에 다양한 방식으로 산재되어 있는 광고의 정확한 View, Click 이벤트를 추적하기 위한 모듈

광고의 View Count Event가 발생할 조건은 다음과 같다.
1. 광고의 전체 면적이 기기의 화면에 완전히 보여지는 경우 (일부가 가려진 경우 x)
2. 단, 스크롤이 멈춘 경우여야만 함
- 사용자가 드래그 중인 경우 1번을 만족해도 x
- 사용자의 드래그가 멈춘 뒤라도 Fling으로 인한 스크롤 중이면 1번을 만족해도 x
- 상하 스크롤 내의 좌우 스크롤이 가능한 광고의 경우 두가지의 스크롤이 모두 멈춰있는 경우
- 일정 시간 후 자동 스크롤 되는 광고의 경우 자동스크롤이 멈춰있는 경우
3. 스크롤이 없어도 화면이 최초 그려졌을 때 온전히 화면에 보여지는 경우
4. 한번 View가 발생한 광고는 페이지가 변경되기 전까지는 다시 View Event를 발생시키지 않아야 함

##

2가지 방식의 추적을 지원합니다.
1. Vertical TableView 안에 TableViewCell 형식으로 광고가 보여지는 경우
2. Vertical TableView 안에 TableViewCell 안에 Horizontal TableView 안에 TableViewCell 형식으로 광고가 보여지는 경우 (상하 스크롤 안에 좌우 스크롤 광고)

이벤트 트래킹은 Rx로 구현되었으며 ViewController의 생명주기에 맞추기 위해 Disposable로 제공하여 ViewController의 DisposeBag을 이용하도록 구현하였습니다.

##

프로젝트 파일은 더미로 클래스 코드는 아래 링크를 이용하세요.

> [클래스 바로가기](https://github.com/magewr/AdvertiseTracker-iOS/blob/main/Advertise-iOS/Advertise-iOS/AdvertiseTracker/AdvertiseTracker.swift)

##

Android : https://github.com/magewr/AdvertiseTracker-Android
