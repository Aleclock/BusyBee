import Foundation
import SwiftUI

/*
 Include events (dropdown menu from 1-5)
 Preview upcoming events in menu bar (from 1h to 12h)
 Lista di calendari check-box
 */
struct ContentView: View {
    @State private var selectionIncludeEvents = 2 // TODO retrieve from storage
    let includeEventsOption = [1, 2, 3, 4, 5]
    
    var body: some View {
        VStack(spacing: 0) {
            //Text("Include events:").frame(maxWidth: .infinity, alignment: .leading)
            Picker("Include events:", selection: $selectionIncludeEvents) {
                ForEach(includeEventsOption, id: \.self) {
                    Text(String($0))
                }
            }.pickerStyle(.menu)
        }.edgesIgnoringSafeArea(.all)
    }
}
