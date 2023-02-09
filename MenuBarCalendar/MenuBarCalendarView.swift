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
                //Text("miao")
                //.font(.system(size: 14))
            }
            //.font(.caption)
        }
        /*
        .onChange(of: viewModel.selectedCoinType) { _ in
            viewModel.updateView()
        }
         */
        /*
        .onAppear {
            viewModel.subscribeToService()
        }
         */
        
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
