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
    @State private var LTMSchedule: MapSchedule?  = nil
    @AppStorage("accuracy") var accurate : Bool = false
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
                    .frame(width: geo.size.width * 0.75, height: 30)
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
                    if(LTMSchedule != nil) {
                        Tab("LTM", systemImage: "arcade.stick") {
                            VStack {
                                if LTMSchedule != nil {
                                    MapScheduleView(schedule: rankedSchedule!)
                                }
                                else {
                                    ProgressView()
                                }
                            }
                            .onAppear{
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
                }
            }
        }
    }
}

struct MapScheduleView: View {
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
                                NotificationBell(map: map)
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
                        addNotification(time: 10, title: "Test Notification", subtitle: "hey?", body: "yooo!")
                    }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
