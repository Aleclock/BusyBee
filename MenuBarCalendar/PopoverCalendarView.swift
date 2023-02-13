import Foundation
import SwiftUI

struct PopoverCalendarView : View {
    @ObservedObject var viewModel : PopoverCalendarViewModel
    
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        Button("Settings", action: {openWindow()})
        Spacer()
    }
    
    func openWindow() {
        let contentView = ContentView()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 450),
            styleMask: [.titled, .closable, .resizable,],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
    }
}

struct PopoverCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverCalendarView(viewModel: .init(title: "Bitcoin"))
    }
}
