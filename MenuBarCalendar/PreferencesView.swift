import SwiftUI
import EventKit
import Defaults

struct PreferencesView: View {
    @State var calendarsBySource: [String: [EKCalendar]] = [:]
    
    @State private var text = ""
    
    @Default(.launchAtLogin) var launchAtLogin
    @Default(.showEventsForPeriod) var showEventsForPeriod
    @Default(.eventsRefreshTime) var eventsRefreshTime
    @Default(.showEventDetails) var showEventDetails
    
    @Default(.selectedCalendarIDs) var selectedCalendarIDs
    
    var calendarModel: CalendarEventsModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("General").font(.headline).bold()
            Toggle("Start at startup", isOn: $launchAtLogin).toggleStyle(.switch)
            
            HStack {
                Picker("Refresh time", selection: $eventsRefreshTime) {
                    Text("10 seconds").tag(EventsRefreshTime.seconds10)
                    Text("30 seconds").tag(EventsRefreshTime.seconds30)
                    Text("60 seconds").tag(EventsRefreshTime.seconds60)
                    Text("2 minutes").tag(EventsRefreshTime.seconds120)
                    Text("5 minutes").tag(EventsRefreshTime.seconds300)
                    Text("10 minutes").tag(EventsRefreshTime.seconds600)
                }.frame(width: 300)
            }
            
            Divider().frame(width: 300)
            
            Text("Appearance").font(.headline).bold()
            HStack {
                Picker("Show events for", selection: $showEventsForPeriod) {
                    Text("Today").tag(ShowEventsForPeriod.today)
                    Text("Today and tomorrow").tag(ShowEventsForPeriod.today_n_tomorrow)
                    Text("Three days").tag(ShowEventsForPeriod.three_days)
                    Text("Full week").tag(ShowEventsForPeriod.full_week)
                }.frame(width: 300)
            }
            
            // TODO mettere textfield
            //TextField("Placeholder", value: $number) //, format: .number)
            
            Toggle("Show event detail", isOn: $showEventDetails).toggleStyle(.switch)
            Divider().frame(width: 300)
            Text("Choose calendars:").font(.headline).bold()
            
            ScrollView {
                VStack (spacing: 15) { // alignment: .leading,
                    ForEach(Array(self.calendarsBySource.keys), id: \.self) { source in
                        Text(source).font(.headline)
                        //Section(header: Text(source).font(.headline)) {
                            ForEach(self.calendarsBySource[source]!, id: \.self) { calendar in
                                CalendarRow(
                                    isOn: self.selectedCalendarIDs.contains(calendar.calendarIdentifier),
                                    title: calendar.title,
                                    color: Color(
                                        red: calendar.color.redComponent,
                                        green: calendar.color.greenComponent,
                                        blue: calendar.color.blueComponent),
                                    //isSelected: self.selectedCalendarIDs.contains(calendar.calendarIdentifier),
                                    action: {
                                        //self.selectedCalendarIDs.removeAll()
                                        //Defaults[.selectedCalendarIDs] = self.selectedCalendarIDs
                                        
                                        if self.selectedCalendarIDs.contains(calendar.calendarIdentifier) {
                                            self.selectedCalendarIDs.removeAll { $0 == calendar.calendarIdentifier }
                                        } else {
                                            self.selectedCalendarIDs.append(calendar.calendarIdentifier)
                                        }
                                        Defaults[.selectedCalendarIDs] = self.selectedCalendarIDs // Ensure Defaults is updated
                                    }
                                )
                            //}
                        }
                    }
                    Spacer()
                }.padding(.vertical, 10)//.border(.red)
            }
        }.onLoad {loadCalendarList()}
            .padding()
    }
    
    func loadCalendarList() {
        calendarsBySource = Dictionary(grouping: calendarModel.calendars) {$0.source.title}
    }
}

struct CalendarRow: View {
    @State var isOn = false // 1
    var title : String
    var color : Color
    //var isSelected: Bool
    var action: () -> Void
    /*
    var isSelected: Bool
    var color: Color
     */
    
    var body: some View {
        HStack {
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .onChange(of: isOn) { value in
                    self.action()
                }
                .tint(color)
            Text(title)
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 10, alignment: .topLeading)
        /*
        .onLoad {
            isOn = isSelected
        }
         */
    }
}

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}

extension View {
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
}
