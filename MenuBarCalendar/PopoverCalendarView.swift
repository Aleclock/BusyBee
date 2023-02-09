import Foundation
import SwiftUI

struct PopoverCalendarView : View {
    @ObservedObject var viewModel : PopoverCalendarViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text(viewModel.title).font(.largeTitle)
            }
        }
    }
}

struct PopoverCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverCalendarView(viewModel: .init(title: "Bitcoin"))
    }
}
