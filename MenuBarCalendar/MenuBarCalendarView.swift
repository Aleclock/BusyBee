import Foundation
import SwiftUI

struct MenuBarCalendarView : View {
    @ObservedObject var viewModel : MenuBarCalendarViewModel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "circle.fill")
                .foregroundColor(viewModel.color)
            
            VStack(alignment: .trailing, spacing: -2) {
                Text(viewModel.name)
            }
            //.font(.caption)
        }
        .onAppear {
            viewModel.subscribeToCalendar()
        }
    }
}

struct MenuBarCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarCalendarView(viewModel: .init(
            name: "Bitcoin",
            color: .green)
        )
    }
}
