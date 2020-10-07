import Foundation

enum ADType : String {
    case HomeBigBanner = "홈_메인배너",
    HomeSmallBanner = "홈_띠배너"
    
    
    /// 실제 이벤트 트래커에 전달할 이벤트 스트링
    /// - Parameters:
    ///   - eventName: 배너 이벤트 스트링
    ///   - isSession: 세션중에 최초 발생 이벤트일 경우 true
    ///   - isClick: true : Click, false : View
    func getEventString(eventName: String, isSession: Bool, isClick: Bool = false) -> String {
        var eventTypeString: String
        eventTypeString = isSession ? "S" : "P"
        eventTypeString += isClick ? "C" : "V"
        if eventTypeString == "PC" {
            eventTypeString = "C"
        }
        return "\(self.rawValue)_\(eventTypeString)_\(eventName)".replaceWhiteSpace()
    }
}
