import Foundation
import SwiftUI

struct MenuBarCalendarView : View {
    @ObservedObject var viewModel : MenuBarCalendarViewModel
    
    var body: some View {
        HStack(spacing: 4) {
            // TODO resize image size
            Image(systemName: "circle.fill")
                .foregroundColor(viewModel.color)
            
            Text(viewModel.name)
                .frame(alignment: .leading)
                .lineLimit(1)          //.font(.caption)
        }
        .onAppear {
            viewModel.subscribeToCalendar()
        }
    }
}

struct MenuBarCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarCalendarView(viewModel: .init(
            name: "",
            color: .green)
        )
    }
}
