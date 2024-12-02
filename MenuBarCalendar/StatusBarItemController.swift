import Foundation
import Cocoa
import EventKit
import SwiftUI
import Combine
import EventKit
import Defaults

class StatusBarItemController {
    private let calendarEventsModel : CalendarEventsModel
    var statusItem: NSStatusItem!
    var statusItemMenu: NSMenu!
    private var isMenuOpen = false
    
    weak var appdelegate: AppDelegate!
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var upcomingEvent : EKEvent? // TODO serve??
    private var events : [EKEvent] = []
    
    init(calendarEventsModel : CalendarEventsModel = .init()) {
        self.calendarEventsModel = calendarEventsModel
        createStatusBarButton()
        self.calendarEventsModel.eventsCalendarSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateInfo() }
            .store(in: &subscriptions)
    }
    
    func createStatusBarButton() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        statusItemMenu = NSMenu(title: "MeetingBar in Status Bar Menu")

        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusMenuBarAction)
        statusItem.button?.sendAction(on: [NSEvent.EventTypeMask.rightMouseDown, NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.leftMouseDown])
        statusItem.menu = statusItemMenu
        statusItem.button?.performClick(nil) // ...and click
        statusItem.menu = nil
        statusItem.button?.title = ""
    }
    
    @objc
    func statusMenuBarAction(sender _: NSStatusItem) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            print ("Doppio click")
        } else if event == nil || event?.type == .leftMouseDown || event?.type == .leftMouseUp {
            // show the menu as normal
            isMenuOpen = true
            updateMenu()
            openMenu()
        }
    }
    
    func openMenu() {
        statusItem.menu = statusItemMenu
        statusItem.button?.performClick(nil) // ...and click
        statusItem.menu = nil
    }
    
    func updateInfo() {
        upcomingEvent = calendarEventsModel.firstEventCalendar
        events = calendarEventsModel.eventsCalendarOne
        
        statusItem.button?.title = getUpdatedButtonValue(event: upcomingEvent)
        /* TODO
        if (!isMenuOpen) {
            updateMenu()
        }
        */
    }
    
    func getUpdatedButtonValue(event : EKEvent?) -> String {
        var title = ""
        if (event != nil) {
            let eventTitle = calendarEventsModel.getTrimmerEventTitle(eventTitle: event!.title, maxLength: 25)
            let isEventStarted = calendarEventsModel.isEventStarted(event: event)
        
            title = isEventStarted.isStarted
            ? eventTitle + " • " + isEventStarted.time + " left"
            : eventTitle + " • in " + isEventStarted.time
        } else {
            title = calendarEventsModel.getFormattedDate(date: Date())
        }
        return title
    }
    
    func createSectionTitle(title : String) {
        let titleItem = statusItemMenu.addItem(
            withTitle: title,
            action: nil,
            keyEquivalent: ""
        )
        
        //titleItem.attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 13)])
        titleItem.isEnabled = false
    }
    
    func updateMenu() {
        statusItemMenu.autoenablesItems = false
        statusItemMenu.removeAllItems()
        
        if (upcomingEvent != nil) {
            let isEventStarted = calendarEventsModel.isEventStarted(event: upcomingEvent)
            let title = isEventStarted.isStarted
                ? "Ending in " + isEventStarted.time
                : "Upcoming in " + isEventStarted.time
            createSectionTitle(title: title)
            createMenuItem(menu: statusItemMenu, event: upcomingEvent!)
        } else {
            createSectionTitle(title: "No scheduled events")
        }
        
        // TODO valutare di inviare al controller direttamente gli eventi divisi
        let splittedEvents = calendarEventsModel.splitEventsByDays()
        
        for day in splittedEvents {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E MMM d"
            
            if (calendarEventsModel.isSameDay(date1: Date(), date2: day.0)) {
                createSectionTitle(title: "Today")
            } else {
                // TODO valutare "Tomorrow"
                createSectionTitle(title: dateFormatter.string(from: day.0))
            }
                
            for event in day.1 {
                let item = statusItemMenu.addItem(
                    withTitle:
                        calendarEventsModel.getTimeString(date: event.startDate) + " • " +
                        calendarEventsModel.getTrimmerEventTitle(eventTitle: event.title, maxLength: 45),
                    action: nil,
                    keyEquivalent: ""
                )
                item.isEnabled = true
                
                let color = NSColor(
                    red: event.calendar.color.redComponent,
                    green: event.calendar.color.greenComponent,
                    blue: event.calendar.color.blueComponent,
                    alpha: 0.8
                    )
                item.image = NSImage(systemSymbolName: "circlebadge.fill", accessibilityDescription: nil)?
                    .tint(color: color)
                
                if (Defaults[.showEventDetails]) {
                    item.submenu = NSMenu(title: "event_detail")
                    createSubMenu(submenu: item.submenu!, event: event)
                }
            }
        }
        
        statusItemMenu.addItem(NSMenuItem.separator())
        
        statusItemMenu.addItem(withTitle: "Preferences", action: #selector(AppDelegate.openPrefecencesWindow), keyEquivalent: ",")
        statusItemMenu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: "q")
    }
    
    func createMenuItem(menu : NSMenu, event: EKEvent) {
        let item = menu.addItem(
            withTitle:
                calendarEventsModel.getTimeString(date: event.startDate) + " • " +
                calendarEventsModel.getTrimmerEventTitle(eventTitle: event.title, maxLength: 45),
            action: nil,
            keyEquivalent: ""
        )
    
        item.isEnabled = true
        
        let color = NSColor(
            red: event.calendar.color.redComponent,
            green: event.calendar.color.greenComponent,
            blue: event.calendar.color.blueComponent,
            alpha: 0.8
            )
        item.image = NSImage(systemSymbolName: "circlebadge.fill", accessibilityDescription: nil)?
            .tint(color: color)
        
        item.submenu = NSMenu(title: "event_detail")
    }
    
    @objc private func refreshSources() {
        print ("miao")
    }
    
    func createSubMenu(submenu: NSMenu, event: EKEvent) {
        // TITLE
        submenu.addItem(createSubMenuItem(title: splitTitle(title: event.title), isActive: true))
        submenu.addItem(NSMenuItem.separator())
        
        if (event.location != nil) {
            submenu.addItem(createSubMenuItem(title: "Location", isActive: false))
            submenu.addItem(createSubMenuItem(title: event.location!, isActive: true))
            submenu.addItem(NSMenuItem.separator())
        }
        
        // DATE
        submenu.addItem(createSubMenuItem(title: "Dates", isActive: false))
        if (calendarEventsModel.isSameDay(date1: event.startDate, date2: event.endDate)) {
            submenu.addItem(createSubMenuItem(title: calendarEventsModel.getFormattedDate(date: event.startDate) + "\t\t" +
                            calendarEventsModel.getTimeString(date: event.startDate) + " - " +
                            calendarEventsModel.getTimeString(date: event.endDate), isActive: true))
        } else {
            submenu.addItem(
                createSubMenuItem (title:
                    calendarEventsModel.getFormattedDate(date: event.startDate) + "\t\t" +
                    calendarEventsModel.getTimeString(date: event.startDate) + "\n" +
                    calendarEventsModel.getFormattedDate(date: event.endDate) + "\t\t" +
                    calendarEventsModel.getTimeString(date: event.endDate), isActive: true
                )
            )
        }
        
        submenu.addItem(NSMenuItem.separator())
        
        if (event.attendees != nil) {
            submenu.addItem(createSubMenuItem(title: "Attendees", isActive: false))
            for attendee in event.attendees! {
                if (attendee.name != event.organizer?.name) {
                    submenu.addItem(createSubMenuItem(title: attendee.name!, isActive: true))
                }
                //print (attendee.participantType.rawValue)
            }
            submenu.addItem(NSMenuItem.separator())
        }
        
        // NOTES
        if (event.notes != nil && event.notes != "") {
            submenu.addItem(createSubMenuItem(title: "Notes", isActive: false))
            submenu.addItem(createSubMenuItem(title: event.notes!, isActive: true))
            submenu.addItem(NSMenuItem.separator())
        }
    }
    
    func createSubMenuItem(title: String, isActive: Bool) -> NSMenuItem {
        let submenu = NSMenuItem()
        submenu.attributedTitle = NSAttributedString(string: title, attributes: nil)
        if (isActive) {
            submenu.action = #selector(refreshSources)
            submenu.target = self
            submenu.keyEquivalent = ""
        }
        //submenu.image = NSImage(systemSymbolName: "circlebadge.fill", accessibilityDescription: nil)
        return submenu
    }
    
    func setAppDelegate(appdelegate: AppDelegate) {
        self.appdelegate = appdelegate
    }
    
    private lazy var contentView: NSView? = {
        let view = (statusItem.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    private func splitTitle(title : String) -> String {
        let words = title.components(separatedBy: " ")
        let maxCharPerLine = 30
        var charCounter = 0
        var title = ""
        
        for w in words {
            if (charCounter + w.count > maxCharPerLine) {
                title += "\n"
                charCounter = w.count
            } else {
                title += " " + w
                charCounter += w.count
            }
        }
        return title
    }
}

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        return NSImage(size: size, flipped: false) { (rect) -> Bool in
            color.set()
            rect.fill()
            self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1.0)
            return true
        }
    }
}
