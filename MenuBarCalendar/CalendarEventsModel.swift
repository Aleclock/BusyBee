import Foundation
import EventKit

class CalendarEventsModel : NSObject {
    var grantedAccess = false
    let eventStore = EKEventStore()
    var events : [EKEvent] = []
    
    // Connect to calendars, request access (if necessary) and retrieve events
    func connectAndRetrieve() {
        requestAccess()
    }
     
    func requestAccess() {
        self.eventStore.requestAccess(to: .event) { (granted, error) in
            if granted, error == nil {
                self.grantedAccess = true
                DispatchQueue.main.async {
                    self.fetchEvents()
                }
            }
        }
    }
    
    func fetchEvents() {
        let byDays = 2
        let weekFromNow = Date().advanced(by: TimeInterval(60*60*24*byDays))
        let predicate = self.eventStore.predicateForEvents(withStart: Date(), end: weekFromNow, calendars: nil)
        let events = self.eventStore.events(matching: predicate)
        self.events = events
        for ev in events {
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
        }
    }
}
