import Foundation
import EventKit
import Combine
import SwiftUI
import Defaults

class CalendarEventsModel {
    
    private var grantedAccess : Bool = false
    var calendars = [EKCalendar]()
    private var waitingSeconds : Int = 1
    let eventStore = EKEventStore()
    
    var eventsByDays = [(Date, [EKEvent])]() // TODO valutare il senso
    
    var showEventsForPeriodObserver : _DefaultsObservation?
    var selectedCalendarIDsObserver : _DefaultsObservation?
    
    // TODO reformat
    let eventsCalendarSubject = CurrentValueSubject<[EKEvent], Never>([])
    var eventsCalendarOne : [EKEvent] { eventsCalendarSubject.value }
    var firstEventCalendar : EKEvent? { eventsCalendarSubject.value.first ?? nil}
    
    @State var TempTextArray: [String] = []
    @AppStorage("textArray", store: UserDefaults.standard) var items: Data = Data()
    
    func setupDefaultObserver() {
        showEventsForPeriodObserver = Defaults.observe(.showEventsForPeriod, options: []) { change in
            if change.oldValue != change.newValue {
                self.fetchEvents()
            }
        }
        
        selectedCalendarIDsObserver = Defaults.observe(.selectedCalendarIDs, options: []) { change in
            if change.oldValue != change.newValue {
                self.fetchEvents()
            }
        }
    }
    
    // Connect to calendars, request access (if necessary) and retrieve events
    func connectAndRetrieve() {
        requestAccess()
    }
    
    private func requestAccess() {
        self.eventStore.requestAccess(to: .event) { (granted, error) in
            if granted, error == nil {
                self.grantedAccess = true
                DispatchQueue.main.async {
                    self.eventStore.sources.forEach { source in
                        source.calendars(for: EKEntityType.event).forEach { (value) in
                            self.calendars.append(value)
                        }
                    }
                    self.fetchEvents()
                }
            }
        }
    }
    
    // TODO convert to EKCalendar
    func getStrings(data: Data) -> [String] {
        return Storage.loadStringArray(data: data)
    }
    
    func fetchEvents() {
        let byDays = Default(.showEventsForPeriod).wrappedValue.rawValue
            
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date()) // Start of today
        let endOfTargetDay = calendar.date(byAdding: .day, value: byDays, to: startOfToday)?.addingTimeInterval(-1) // End of nth day
        
        guard let endOfTargetDay = endOfTargetDay else { return }
        
        let selectedCalendarIDs = Defaults[.selectedCalendarIDs]
        
        if selectedCalendarIDs.isEmpty {
            eventsCalendarSubject.send([]) // Send an empty event list
            return
        }
        
        let selectedCalendars = eventStore.calendars(for: .event).filter { selectedCalendarIDs.contains($0.calendarIdentifier) }
            
        
        let predicate = self.eventStore.predicateForEvents(withStart: startOfToday, end: endOfTargetDay, calendars: selectedCalendars)
        let events = self.eventStore.events(matching: predicate)
        
        var newDictionaryOne = [EKEvent]()
        events.forEach { (value) in
            newDictionaryOne.append(value)
        }
        eventsCalendarSubject.send(newDictionaryOne)
    }
    
    func scheduleUpdate() {
        let refreshInterval = Default(.eventsRefreshTime).wrappedValue.rawValue
        let dispatchAfter = DispatchTimeInterval.seconds(refreshInterval)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter) {
            self.fetchEvents()
            self.scheduleUpdate()
        }
    }
    
    // TODO modificare 0 e 1
    func splitEventsByDays() -> [(Date, [EKEvent])]{
        var splittedEvents : [(Date, [EKEvent])] = []
        
        if (eventsCalendarOne.count == 0) {
            return splittedEvents
        }
            
        var currentDay = eventsCalendarOne[0].startDate ?? Date()
        var daysEvents = [EKEvent]()
        var daysEventsTuple = (day: Date(), events: daysEvents)
        
        for d in eventsCalendarOne {
            if (isSameDay(date1: d.startDate, date2: currentDay)) {
                daysEvents.append(d)
            } else {
                daysEventsTuple.day = currentDay
                daysEventsTuple.events = daysEvents
                splittedEvents.append(daysEventsTuple)
                
                currentDay = d.startDate
                daysEvents.removeAll()
                daysEvents.append(d)
            }
        }
        
        daysEventsTuple.day = currentDay
        daysEventsTuple.events = daysEvents
        splittedEvents.append(daysEventsTuple)
        
        return splittedEvents
    }
    
    public func isSameDay(date1 : Date, date2 : Date) -> Bool {
        let fromDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date1))
        let toDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date2))
        let diff = Calendar.current.dateComponents([.day], from: fromDate!, to: toDate!)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    /// Returns a Date in HH:mm format
    public func getTimeString(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    /// Returns a Date in E d MMM yyyy format
    public func getFormattedDate(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E d MMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    public func getTrimmerEventTitle(eventTitle : String?, maxLength: Int) -> String {
        var title = eventTitle ?? ""
        if (title.count > maxLength) {
            title = title.prefix(maxLength) + "..."
        }
        return title
    }
    
    /// Determine if an event is already started or not. Return a bool and the from start/to end
    public func isEventStarted(event: EKEvent?) -> (isStarted : Bool, time: String) {
        var result = (isStarted: false, time: "")
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        if (event == nil) {
            return result
        }
        
        if (event!.startDate < Date()) {
            let time = formatter.string(from: Date().distance(to: event!.endDate))!
            result = (true, time)
        } else {
            let time = formatter.string(from: Date().distance(to: event!.startDate))
            result = (false, time ?? "")
        }
            
        return result
    }
    
}
