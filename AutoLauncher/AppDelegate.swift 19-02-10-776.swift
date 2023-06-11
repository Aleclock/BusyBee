import AppKit

class AutoLauncherAppDelegate: NSObject, NSApplicationDelegate {
    
    enum Constants {
        static let mainAppBundleID = "com.CAproj.MenuBarCalendar"
    }
    
    /*
    private func launchOrTerminateMainApp() {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains { $0.bundleIdentifier == Constants.mainAppBundleID }

        if !isRunning {
            let killAutoLauncherNotificationName = Notification.Name(rawValue: "killAutoLauncher")
            DistributedNotificationCenter.default().addObserver(self,
                                                                selector: #selector(terminateApp),
                                                                name: killAutoLauncherNotificationName,
                                                                object: Constants.mainAppBundleID)
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            // This Auto Launcher app is actually embedded inside the main app bundle
            // under the subdirectory Contents/Library/LoginItems.
            // So there will be a total of 3 path components to be deleted.
            for _ in 1 ... 3 {
                components.removeLast()
            }
            components.append(Constants.appTargetPlatform)
            components.append(Constants.mainAppName)

            let actualAppPath = NSString.path(withComponents: components)
            NSWorkspace.shared.launchApplication(actualAppPath)
        } else {
            terminateApp()
        }
    }
    */
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains{
            $0.bundleIdentifier == Constants.mainAppBundleID
        }
        
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            print ("**** LaunchingApp")
            for _ in 1...3 {
                path = path.deletingLastPathComponent as NSString
            }
            let applicationPathString = path as String
            guard let pathURL = URL(string: applicationPathString) else {return}
            NSWorkspace.shared.openApplication(
                at: pathURL,
                configuration: NSWorkspace.OpenConfiguration(),
                completionHandler: nil
            )
        } else {
            print ("**** TerminateApp")
            terminateApp()
        }
    }
    
    /// Terminate the app if the launcher is not needed anymore.
    @objc
    private func terminateApp() {
        NSApp.terminate(nil)
    }

}
