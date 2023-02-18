import SwiftUI

struct PreferencesView: View {
    @State private var selectionIncludeEvents = 2 // TODO retrieve from storage
    let includeEventsOption = [1, 2, 3, 4, 5]
    
    var body: some View {
        VStack {
            Picker("Include events:", selection: $selectionIncludeEvents) {
                ForEach(includeEventsOption, id: \.self) {
                    Text(String($0))
                }
            }.pickerStyle(.menu)
        }.padding()
    }
}
