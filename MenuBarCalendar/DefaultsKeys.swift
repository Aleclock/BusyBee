import Defaults
import Foundation

extension Defaults.Keys {
    static let launchAtLogin = Key<Bool>("launchAtLogin", default: false)
    static let showEventDetails = Key<Bool>("showEventDetails", default: false)
    static let showEventsForPeriod = Key<ShowEventsForPeriod>("showEventsForPeriod", default: .today)
    static let selectedCalendarIDs = Key<[String]>("selectedCalendarIDs", default: [])
}

enum ShowEventsForPeriod: String, _DefaultsSerializable {
    case today
    case today_n_tomorrow
    case three_days
    case full_week
}
