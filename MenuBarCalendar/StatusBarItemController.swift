import Foundation
import Cocoa
import EventKit
import SwiftUI
import Combine
import EventKit

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
        self.calendarEventsModel.eventsCalendarOneSubject
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
        //statusItem.button?.image = NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)
        //statusItem.button?.imagePosition = .imageLeft
        statusItem.button?.title = "miao"
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
        
        updateButton(event: upcomingEvent)
        /* TODO
        if (!isMenuOpen) {
            updateMenu()
        }
        */
    }
    
    func updateButton(event : EKEvent?) {
        statusItem.button?.title = getMenuBarMessage(event: event)
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
    
    func tintedImage(_ image: NSImage, tint: NSColor) -> NSImage {
        guard let tinted = image.copy() as? NSImage else { return image }
        tinted.lockFocus()
        tint.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        //NSRectFillUsingOperation(imageRect, .sourceAtop)
        imageRect.fill(using: .sourceAtop)

        tinted.unlockFocus()
        return tinted
    }
    
    func updateMenu() {
        statusItemMenu.autoenablesItems = false
        statusItemMenu.removeAllItems()
        
        if (upcomingEvent != nil) {
            createSectionTitle(title: "Upcoming")
            // TODO Upcoming in 10h "
            // TODO Ending in 33m
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
                    withTitle: calendarEventsModel.getTimeString(date: event.startDate) + " • " + event.title,
                    action: nil,
                    keyEquivalent: ""
                )
                
                let color = NSColor(
                    red: event.calendar.color.redComponent,
                    green: event.calendar.color.greenComponent,
                    blue: event.calendar.color.blueComponent,
                    alpha: 0.8
                    )
                item.image = NSImage(systemSymbolName: "circlebadge.fill", accessibilityDescription: nil)?
                    .tint(color: color)
                
                item.isEnabled = true
                item.submenu = NSMenu(title: "Event detail")
                
                let dismissMeetingItem = item.submenu!.addItem(
                    withTitle: "Miao",
                    action: nil, //#selector(dismissNextMeetingAction),
                    keyEquivalent: ""
                    )
            }
        }
        
        statusItemMenu.addItem(NSMenuItem.separator())
        
        statusItemMenu.addItem(withTitle: "Preferences", action: #selector(AppDelegate.openPrefecencesWindow), keyEquivalent: ",")
        statusItemMenu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: "q")
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
        } else {
            // TODO show Date
        }
        return title
    }
    
    func setAppDelegate(appdelegate: AppDelegate) {
        self.appdelegate = appdelegate
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
