import Cocoa
import LaunchAtLogin
import Defaults
import SwiftUI
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: StatusBarItemController!
    var calendarEventsModel = CalendarEventsModel()
    
    var launchAtLoginObserver : _DefaultsObservation?
    
    var statusItem: NSStatusItem!
    weak var preferencesWindow: NSWindow!
    
    private lazy var contentView: NSView? = {
        let view = (statusItem.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupCalendarEventsModel()
        statusBarItem = StatusBarItemController(calendarEventsModel: calendarEventsModel)
        statusBarItem.setAppDelegate(appdelegate: self)
        // When our main application starts, we have to kill
        // the auto launcher application if it's still running.
        
        //postNotificationForAutoLauncher()
    }
    
    func setupCalendarEventsModel() {
        calendarEventsModel.connectAndRetrieve()
        calendarEventsModel.scheduleUpdate()
        setupDefaultObserver()
    }
    
    func setupDefaultObserver() {
        launchAtLoginObserver = Defaults.observe(.launchAtLogin, options: []) { change in
            if change.oldValue != change.newValue {
                LaunchAtLogin.isEnabled = change.newValue
                print(LaunchAtLogin.isEnabled)
                //SMLoginItemSetEnabled(AutoLauncher.bundleIdentifier as CFString, change.newValue)
            }
        }
    }
    
    private func postNotificationForAutoLauncher() {
        let runningApps = NSWorkspace.shared.runningApplications
        let isLauncherRunning = runningApps.contains { $0.bundleIdentifier == AutoLauncher.bundleIdentifier }
        if isLauncherRunning {
            //DistributedNotificationCenter.default().post(name: .killLauncher, object: nil)
        }
        /*
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains { $0.bundleIdentifier == AutoLauncher.bundleIdentifier }
        if isRunning {
            let killAutoLauncherNotificationName = Notification.Name(rawValue: "killAutoLauncher")
            DistributedNotificationCenter.default().post(name: killAutoLauncherNotificationName,
                                                         object: Bundle.main.bundleIdentifier)
        }
        */
    }
    
    @objc
    func openPrefecencesWindow(_: NSStatusBarButton?) {
        NSLog("Open preferences window")
        let contentView = PreferencesView(calendarModel: calendarEventsModel)

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
    
    @objc
    func quit(_: NSStatusBarButton) {
        NSLog("User click Quit")
        NSApplication.shared.terminate(self)
    }
}

public enum AutoLauncher {
    static let bundleIdentifier: String = "com.CAproj.AutoLauncher"
}
