//
//  MenuBarCalendarApp.swift
//  MenuBarCalendar
//
//  Created by Alessandro Clocchiatti on 09/02/23.
//

import SwiftUI

@main
struct MenuBarCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView().frame(width: 0, height: 0)
        }
    }
}
