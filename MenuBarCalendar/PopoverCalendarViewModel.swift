import Foundation

class PopoverCalendarViewModel: ObservableObject {
    @Published private(set) var title: String
    
    init (title: String = "") {
        self.title = title
    }
    
    func updateView() {
        // TODO
        self.title = "miao"
    }
}
