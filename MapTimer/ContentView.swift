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
    private var schedule = CurrentMapRotation()
    var body: some View {
        GeometryReader { geo in
            VStack{
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
                ForEach(schedule.upcomingMaps(at: .now, range: 0...(UIDevice.current.orientation.isLandscape ? 2 : schedule.rotation.count)), id: \.availableTo) { map in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(map.mapColorTX().gradient)
                        .overlay{
                            VStack{
                                Text(map.mapName()) + Text((map.availableAt...map.availableTo).contains(.now) ? schedule.rotationInterval > 43200 ? " until" : "" : schedule.rotationInterval > 43200 ? " on" : " at")
                                Text(map.availableAt, style: schedule.rotationInterval > 43200 ? .date : (map.availableAt...map.availableTo).contains(.now) ? .timer : .time)
                            }
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                            .fontWeight(.semibold)
                            .font((map.availableAt...map.availableTo).contains(.now) ? .largeTitle : .title2)
                            .fontDesign(map.fontStyle())
                        }
                        .padding(5)
                        .frame(height: (map.availableAt...map.availableTo).contains(.now) ? geo.size.height * 0.5 : nil)
                }
            }
            .padding(20)
        }
        
    }
}

#Preview {
    ContentView()
}
