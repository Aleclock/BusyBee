import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var menuBarCalendarViewModel : MenuBarCalendarViewModel!
    var popoverCalendarViewModel : PopoverCalendarViewModel!
    var calendarEventsModel = CalendarEventsModel()
    
    
    var statusItem: NSStatusItem!
    let popover = NSPopover()
    
    private lazy var contentView: NSView? = {
        let view = (statusItem.value(forKey: "window") as? NSWindow)?.contentView
        return view
    }()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupCalendarEventsModel()
        setupMenuBar()
        setupPopover()
    }
    
    func setupCalendarEventsModel() {
        calendarEventsModel.connectAndRetrieve()
        calendarEventsModel.scheduleUpdate()
    }
    
}

// MARK: - MENU BAR

extension AppDelegate {

    
    // https://stackoverflow.com/questions/64949572/how-to-create-status-bar-icon-and-menu-in-macos-using-swiftui
    func setupMenuBar() {
        menuBarCalendarViewModel = MenuBarCalendarViewModel(calendarEventsModel: calendarEventsModel)
        statusItem = NSStatusBar.system.statusItem(withLength: 200) // TODO farla flessibile
        //statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let contentView = self.contentView,
              let menuButton = statusItem.button
        else { return }
        
        
        let hostingView = NSHostingView(rootView: MenuBarCalendarView(viewModel: menuBarCalendarViewModel))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
    
        //menuButton.action = #selector(menuButtonClicked)
    }
    
    @objc func menuButtonClicked() {
        if popover.isShown {
            popover.performClose(nil)
            return
        }
        
        guard let menuButton = statusItem.button else { return }
        let positioningView = NSView(frame: menuButton.bounds)
        positioningView.identifier = NSUserInterfaceItemIdentifier("positioningView")
        menuButton.addSubview(positioningView)
        
        popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: .maxY)
        menuButton.bounds = menuButton.bounds.offsetBy(dx: 0, dy: menuButton.bounds.height)
        popover.contentViewController?.view.window?.makeKey()
    }
    
}

// MARK: - POPOVER

extension AppDelegate: NSPopoverDelegate {

    func setupPopover() {
        popoverCalendarViewModel = .init()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = .init(width: 240, height: 280)
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(
            rootView: PopoverCalendarView(viewModel: popoverCalendarViewModel).frame(maxWidth: .infinity, maxHeight: .infinity).padding()
        )
        popover.delegate = self
    }
    
    func popoverDidClose(_ notification: Notification) {
        let positioningView = statusItem.button?.subviews.first {
            $0.identifier == NSUserInterfaceItemIdentifier("positioningView")
        }
        positioningView?.removeFromSuperview()
    }
}
