import Foundation
import SwiftUI
import Combine
import EventKit

class MenuBarCalendarViewModel : ObservableObject {
    
    @Published private(set) var name: String
    @Published private(set) var color: Color
    private let calendarEventsModel : CalendarEventsModel
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(name: String = "", color: Color = .green, calendarEventsModel : CalendarEventsModel = .init()){
        self.name = name
        self.color = color
        self.calendarEventsModel = calendarEventsModel
    }
    
    func subscribeToCalendar() {
        calendarEventsModel.eventsCalendarOneSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateView() }
            .store(in: &subscriptions)
    }
    
    func updateView() {
        let upcomingEvent = calendarEventsModel.firstEventCalendar
        self.name = getMenuBarMessage(event: upcomingEvent)
        
    }
    
    private func getMenuBarMessage (event : EKEvent?) -> String {
        var title = ""
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        if (event != nil) {
            if (event!.startDate < Date()) {
                let time = formatter.string(from: Date().distance(to: event!.endDate))!
                title = event!.title + " • " + time + " left"
            } else {
                let time = formatter.string(from: Date().distance(to: event!.startDate))
                title = event!.title + " • " + "in " + (time ?? "")
            }
            // TODO if not started
                // Title * in 2h 13m
            // TODO if already started
                // Title * 1h 42m left
        } else {
            // TODO show date
        }
        return title
    }
}
