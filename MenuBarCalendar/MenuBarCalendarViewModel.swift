import Foundation
import SwiftUI

class MenuBarCalendarViewModel : ObservableObject {
    
    @Published private(set) var name: String
    @Published private(set) var color: Color
    
    private let calendarEventsModel : CalendarEventsModel
    
    init(name: String = "", color: Color = .green, calendarEventsModel : CalendarEventsModel = .init()){
        self.name = name
        self.color = color
        self.calendarEventsModel = calendarEventsModel
    }
    
    func updateView() {
        self.name = "Miao"
    }
}
