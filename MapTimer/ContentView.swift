//
//  ContentView.swift
//  MapTimer
//
//  Created by Jack Kroll on 3/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var pubsSchedule : MapSchedule? = nil
    @State private var rankedSchedule : MapSchedule? = nil
    @State private var LTMSchedule: [MapSchedule]  = []
    @AppStorage("accuracy") var accurate : Bool = false
    @State var displayInaccurate: Bool = false
    private var schedule = CurrentMapRotation()
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0){
                if !accurate {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.background.secondary)
                    .overlay{
                        HStack{
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Schedule may be outdated")
                        }
                        .foregroundStyle(.orange)
                        .fontWeight(.semibold)
                    }
                    .onTapGesture {
                        displayInaccurate = true
                    }
                    .frame(width: geo.size.width * 0.75, height: 30)
                    .sheet(isPresented: $displayInaccurate) {
                        VStack {
                            VStack{
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Schedule may be outdated")
                            }
                            .font(.title)
                            .foregroundStyle(.orange)
                            .fontWeight(.semibold)
                            Text("The application was unable to make a connection to the server, this may be due to a network issue or a server outage.\nIf this issue persists, please contact me at support@jackk.dev")
                        }
                        .padding()
                        .presentationDetents([.fraction(0.3)])
                    }
                }
                TabView{
                    Tab("Casual", systemImage: "gamecontroller.fill") {
                        VStack {
                            if pubsSchedule != nil {
                                MapScheduleView(schedule: pubsSchedule!)
                                
                            }
                            else {
                                ProgressView()
                            }
                        }
                        .onAppear{
                            Task {
                                pubsSchedule = try await schedule.fetchPlaylist(playlist: .regular)
                            }
                        }
                    }
                    if(LTMSchedule.count > 0) {
                        ForEach(LTMSchedule, id: \.takeoverName) { ltm in
                            Tab(ltm.takeoverName ?? "LTM", systemImage: ltm.takeoverSystemImage ?? "clock.badge") {
                                MapScheduleView(schedule: ltm)
                            }
                        }
                    }
                    Tab("Ranked", systemImage: "bolt.fill") {
                        VStack {
                            if rankedSchedule != nil {
                                MapScheduleView(schedule: rankedSchedule!)
                            }
                            else {
                                ProgressView()
                            }
                        }
                        .onAppear{
                            Task {
                                rankedSchedule = try await schedule.fetchPlaylist(playlist: .ranked)
                            }
                        }
                    }
                    Tab("About", systemImage: "info.circle") {
                        VStack {
                            ScrollView{
                                VStack(alignment: .leading) {
                                    Text("Disclaimer")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text("The project and people involved are not sponsored, affiliated or endorsed by EA/Respawn/EAC in any way. This is made by a player, for players. All images, icons and trademarks belong to their respective owner. Apex Legends is a registered trademark of EA. Game assets, materials and icons belong to Electronic Arts. Be aware, EA and Respawn do not endorse the content of this website nor are responsible for this content.")
                                }
                                Divider()
                                VStack(alignment: .leading) {
                                    Text("Experiencing Issues?")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text("This project relys upon my server being up to date, due to this there may be some delay after a update. However, please reach out to me if there are prolonged issues or you encounter other issues")
                                    Button("Report Issue") {
                                        UIApplication.shared.open(URL(string: "mailto:support@jackk.dev?subject=Map%20Timer%20Issue")!)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.large)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            //see if ltms exist
            .onAppear{
                Task {
                    LTMSchedule = await schedule.fetchLTMS()
                }
            }
        }
    }
}

struct MapScheduleView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @State var schedule : MapSchedule
    //@State var map: Map? = nil
    
    var body : some View {
        GeometryReader { geo in
            VStack {
                if (schedule.takeoverName != nil) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.background.secondary)
                        .overlay{
                            HStack{
                                Image(systemName: "bolt.badge.clock.fill")
                                Text(schedule.takeoverName ?? "Takeover Active")
                            }
                            .foregroundStyle(.primary)
                            .fontWeight(.semibold)
                        }
                        .frame(width: geo.size.width * 0.75, height: 30)
                }
                ForEach(schedule.upcomingMaps(at: .now, range: 0...(UIDevice.current.orientation.isLandscape ? 2 : schedule.rotation.count)), id: \.availableTo) { map in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(map.mapColorTX().gradient)
                        .overlay{
                            ZStack{
                                MapCard(map: map)
                                if !(map.isAvailable(at: .now)) {
                                    NotificationBell(map: map)
                                }
                            }
                            
                        }
                        .frame(height: map.isAvailable(at: .now) ? geo.size.height * 0.5 : nil)
                        .padding(5)
                }
            }
        }
    }
}

struct MapCard : View {
    @State var map : Map
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack{
            Text(map.headerText())
            map.timerText()
        }
        .padding()
        .multilineTextAlignment(.center)
        .foregroundStyle(colorScheme == .dark ? .black : .white)
        .fontWeight(.semibold)
        .font((map.availableAt...map.availableTo).contains(.now) ? .largeTitle : .title2)
        .fontDesign(map.fontStyle())
        
    }
}

struct NotificationBell : View {
    @State var map : Map
    @Environment(\.colorScheme) var colorScheme
    @State var toggleSheet = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.background.tertiary)
                    .onTapGesture {
                        toggleSheet = true
                    }
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $toggleSheet) {
            NotificationSheet(map: map)
                .presentationDetents([.fraction(0.4)])
        }
    }
}

struct NotificationSheet : View {
    @Environment(\.dismiss) private var dismiss
    @State var map : Map
    @State var notifyMeBefore : Bool = false
    @State var notifyBeforeTime : Double = 10
    @State var notifyMeUponChange : Bool = true
    var body: some View {
        ZStack {
            VStack (spacing: 20){
                Text("One Time Notification")
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .padding(.top, 20)
                Toggle(notifyMeBefore ? "Notify me \(Int(notifyBeforeTime)) \(notifyBeforeTime == 1 ? "minute" :"minutes") before" :"Notify me before", isOn: $notifyMeBefore.animation())
                if (notifyMeBefore) {
                    Slider(value: $notifyBeforeTime,
                           in: 1...30,
                           step: 1,
                           minimumValueLabel: Text("1 min"),
                           maximumValueLabel: Text("30 min"),
                           label: { Text("Minutes before") }
                    )
                }
                
                Toggle("Notify me when \(map.mapName()) is available", isOn: $notifyMeUponChange)
                
                Button("Enable a one time notification") {
                    if (notifyMeUponChange) {
                        addNotification(time: Date.now.distance(to: map.availableAt), title: "\(map.mapName()) is now available!", subtitle: "Avilable for the next \(Int(map.rotationInterval()/60)) minutes", body: "")
                    }
                    if (notifyMeBefore) {
                        addNotification(time: Date.now.distance(to: map.availableAt) - Double(notifyBeforeTime * 60), title: "\(map.mapName()) will be available in \(notifyBeforeTime)) minutes", subtitle: "", body: "")
                    }
                }
                .fontWeight(.semibold)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled((!notifyMeBefore && !notifyMeUponChange) || map.isAvailable(at: .now))
            }
            .padding(20)
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                        .symbolRenderingMode(.hierarchical)
                        .onTapGesture {
                            dismiss()
                        }
                        
                }
                Spacer()
            }
        }
    }
}


#Preview {
    ContentView()
}
