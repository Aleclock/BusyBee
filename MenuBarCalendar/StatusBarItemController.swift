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
        print (events.count)
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
    
    func updateMenu() {
        statusItemMenu.autoenablesItems = false
        statusItemMenu.removeAllItems()
        
        let today = Date()
        let days = 3 // TODO save in default (appstorage)
        
        if (upcomingEvent != nil) {
            createSectionTitle(title: "Upcoming")
            // TODO Upcoming in 10h "
            // TODO Ending in 33m
        }
        
        for i in 0...days-1 {
            let day = Calendar.current.date(byAdding: .day, value: i, to: today)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E MMM d"
            
            if (i == 0) {
                createSectionTitle(title: "Today")
            } else {
                createSectionTitle(title: dateFormatter.string(from: day))
            }
            // TODO filter events by days
            // TODO create section of events
        }
        
        let text = "status_bar_empty_calendar_message"
        let item = statusItemMenu.addItem(withTitle: "", action: nil, keyEquivalent: "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        item.attributedTitle = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        item.isEnabled = true
        
        statusItemMenu.addItem(NSMenuItem.separator())
        
        let quickActionsItem = statusItemMenu.addItem(
            withTitle: "status_bar_quick_actions",
            action: nil,
            keyEquivalent: ""
        )
        quickActionsItem.isEnabled = true
        quickActionsItem.submenu = NSMenu(title: "status_bar_quick_actions")
        let dismissMeetingItem = quickActionsItem.submenu!.addItem(
            withTitle: "Miao",
            action: nil, //#selector(dismissNextMeetingAction),
            keyEquivalent: ""
        )
        dismissMeetingItem.target = self
        
        let undiDismissMeetingsItem = quickActionsItem.submenu!.addItem(
            withTitle: "status_bar_menu_remove_all_dismissals",
            action: nil, //#selector(undismissMeetingsActions),
            keyEquivalent: ""
        )
        undiDismissMeetingsItem.target = self
        
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
