import Foundation
import EventKit
import Combine
import SwiftUI

class CalendarEventsModel {
    
    private var grantedAccess : Bool = false
    private var waitingSeconds : Int = 1
    let eventStore = EKEventStore()
    
    let eventsCalendarSubject = CurrentValueSubject<[String : EKEvent], Never>([:])
    var eventsCalendar: [String: EKEvent] { eventsCalendarSubject.value }
    
    // TODO we use this
    let eventsCalendarOneSubject = CurrentValueSubject<[EKEvent], Never>([])
    var eventsCalendarOne : [EKEvent] { eventsCalendarOneSubject.value }
    var firstEventCalendar : EKEvent? { eventsCalendarOneSubject.value.first ?? nil}
    
    @State var TempTextArray: [String] = []
    @AppStorage("textArray", store: UserDefaults.standard) var items: Data = Data()
    
    
    
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
                        //print (source.title)
                        source.calendars(for: EKEntityType.event).forEach { (value) in
                            //print (value.title)
                            //print (value.color)
                        }
                        //print ("---")
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
    
    // TODO convert to EKCalendar
    func addAlbum() {
        var tmpAlbums = getStrings(data: items)
        tmpAlbums.append("Album # Miao")
        items = Storage.archiveStringArray(object: tmpAlbums)
    }
    
    func fetchEvents() {
        //addAlbum()
        
        let byDays = 2
        let weekFromNow = Date().advanced(by: TimeInterval(60*60*24*byDays))
        
        let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: weekFromNow, calendars: nil)
        let events = self.eventStore.events(matching: predicate)
        
        var newDictionary = [String: EKEvent]()
        var newDictionaryOne = [EKEvent]()
        events.forEach { (value) in
            newDictionary["miao"] = value
            newDictionaryOne.append(value)
        }
            /*
            if (ev.title != nil) {
                print (ev.title!)
            }
            print (ev.availability.rawValue)
            print (ev.isAllDay)
            print (ev.startDate ?? "NaN")
            print (ev.endDate ?? "NaN")
            //print (ev.status.hashValue)
            print (ev.status.rawValue) // 0: none, 1: confirmed, 2: tentative, 3: canceled
            print ("---")
             */
        //print (newDictionary.count)
        //let mergedDictionary = eventsCalendar.merging(newDictionary){ $1 }
        //let mergedDictionary = eventsCalendarOne.mer
        eventsCalendarOneSubject.send(newDictionaryOne)
        //eventsCalendarSubject.send(newDictionary)
    }
    
    func scheduleUpdate() {
        let dispatchAfter = DispatchTimeInterval.seconds(waitingSeconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter) {
            self.fetchEvents()
            self.scheduleUpdate()
        }
    }
    
    func splitEventsByDays() -> [(Date, [EKEvent])]{
        var splittedEvents : [(Date, [EKEvent])] = []
        
        if (eventsCalendarOne.count == 0) {
            return splittedEvents
        }
            
        var currentDay = eventsCalendarOne[0].startDate ?? Date()
        var daysEvents = [EKEvent]()
        var daysEventsTuple = (Date(), daysEvents)
        
        for d in eventsCalendarOne {
            if (isSameDay(date1: d.startDate, date2: currentDay)) {
                daysEvents.append(d)
            } else {
                daysEventsTuple.0 = currentDay
                daysEventsTuple.1 = daysEvents
                splittedEvents.append(daysEventsTuple)
                
                currentDay = d.startDate
                daysEvents.removeAll()
                daysEvents.append(d)
            }
        }
        
        daysEventsTuple.0 = currentDay
        daysEventsTuple.1 = daysEvents
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
    
    public func getTimeString(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}
