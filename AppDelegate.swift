import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: StatusBarItemController!
    var menuBarCalendarViewModel : MenuBarCalendarViewModel!
    var popoverCalendarViewModel : PopoverCalendarViewModel!
    var calendarEventsModel = CalendarEventsModel()
    
    
    var statusItem: NSStatusItem!
    let popover = NSPopover()
    weak var preferencesWindow: NSWindow!
    
    private lazy var contentView: NSView? = {
        let view = (statusItem.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupCalendarEventsModel()
        statusBarItem = StatusBarItemController(calendarEventsModel: calendarEventsModel)
        statusBarItem.setAppDelegate(appdelegate: self)
    }
    
    func setupCalendarEventsModel() {
        calendarEventsModel.connectAndRetrieve()
        calendarEventsModel.scheduleUpdate()
    }
    
    @objc
    func quit(_: NSStatusBarButton) {
        NSLog("User click Quit")
        NSApplication.shared.terminate(self)
    }
}

// MARK - WINDOW

extension AppDelegate {
    @objc
    func openPrefecencesWindow(_: NSStatusBarButton?) {
        NSLog("Open preferences window")
        let contentView = PreferencesView()

        if let preferencesWindow {
            // if a window is already open, focus on it instead of opening another one.
            NSApplication.shared.activate(ignoringOtherApps: true)
            preferencesWindow.makeKeyAndOrderFront(nil)
            return
        } else {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 610),
                styleMask: [.closable, .titled, .resizable],
                backing: .buffered,
                defer: false
            )

            window.title = "Preferences"
            window.contentView = NSHostingView(rootView: contentView)
            window.makeKeyAndOrderFront(nil)
            // allow the preference window can be focused automatically when opened
            NSApplication.shared.activate(ignoringOtherApps: true)

            let controller = NSWindowController(window: window)
            controller.showWindow(self)

            window.center()
            window.orderFrontRegardless()

            preferencesWindow = window
        }
    }
}
