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
    @State private var errorFetching: Bool = false
    @State var displayInaccurate: Bool = false
    private var schedule = CurrentMapRotation()
    
    @Environment(\.scenePhase) var scenePhase
    
    
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
                                ProgressHelper()
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
                                ProgressHelper()
                            }
                        }
                    }
                    Tab("About", systemImage: "info.circle") {
                        AboutTab()
                        .padding()
                    }
                }
            }
            .onChange(of: scenePhase) { _, new in
                if (new == .active) {
                    Task {
                        print("Updating data!")
                        let shouldUpdate =  await schedule.shouldUpdate()
                        pubsSchedule = try await schedule.fetchPlaylist(playlist: .regular, forceUpdate: shouldUpdate)
                        rankedSchedule = try await schedule.fetchPlaylist(playlist: .ranked, forceUpdate: shouldUpdate)
                        LTMSchedule = await schedule.fetchLTMS()
                    }
                }
            }
        }
    }
}

struct MapScheduleView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var schedule : MapSchedule
    @State var upcomingMaps : [Map] = []
    @State var changeMap : Date? = nil
    
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
                ForEach(upcomingMaps, id: \.availableTo) { map in
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
            .onAppear() {
                upcomingMaps = schedule.upcomingMaps(at: .now, range: 0...(UIDevice.current.orientation.isLandscape ? 2 : schedule.rotation.count))
                changeMap = upcomingMaps.first?.availableTo
            }
            
            .onChange(of: changeMap) { old, new in
                if changeMap != nil {
                    DispatchQueue.main.asyncAfter(deadline:  .now() + Date.now.distance(to: changeMap!)) {
                        upcomingMaps = schedule.upcomingMaps(at: .now, range: 0...(UIDevice.current.orientation.isLandscape ? 2 : schedule.rotation.count))
                        changeMap = upcomingMaps.first?.availableTo
                    }
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



#Preview {
    ContentView()
}
