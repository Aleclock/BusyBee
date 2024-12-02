import Foundation
import Defaults

extension Defaults.Keys {
    static let launchAtLogin = Key<Bool>("launchAtLogin", default: false)
    static let showEventDetails = Key<Bool>("showEventDetails", default: false)
    static let showEventsForPeriod = Key<ShowEventsForPeriod>("showEventsForPeriod", default: .today)
    static let selectedCalendarIDs = Key<[String]>("selectedCalendarIDs", default: [])
    static let eventsRefreshTime = Key<EventsRefreshTime>("eventsRefreshTime", default: .seconds60)
}

enum ShowEventsForPeriod: Int, _DefaultsSerializable {
    case today = 1
    case today_n_tomorrow = 2
    case three_days = 3
    case full_week = 7
}

enum EventsRefreshTime: Int, _DefaultsSerializable {
    case seconds10 = 10
    case seconds30 = 30
    case seconds60 = 60
    case seconds120 = 120
    case seconds300 = 300
    case seconds600 = 600
}
