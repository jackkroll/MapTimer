//
//  ContentView.swift
//  WatchMapTimer Watch App
//
//  Created by Jack Kroll on 5/24/25.
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
    
    var body: some View {
        VStack {
            TabView {
                Tab {
                    VStack {
                        if pubsSchedule != nil {
                            ZStack {
                                MapView(schedule: pubsSchedule!, title: "Pubs", symbol: "gamecontroller.fill")
                            }
                        }
                        else {
                            ProgressView()
                        }
                    }
                }
                if(LTMSchedule.count > 0) {
                    ForEach(LTMSchedule, id: \.takeoverName) { ltm in
                        Tab(ltm.takeoverName ?? "LTM", systemImage: ltm.takeoverSystemImage ?? "clock.badge") {
                            MapView(schedule: ltm, title: ltm.takeoverName ?? "LTM", symbol: ltm.takeoverSystemImage ?? "clock.badge")
                        }
                    }
                }
                Tab {
                    VStack {
                        if rankedSchedule != nil {
                            MapView(schedule: rankedSchedule!, title: "Ranked", symbol: "bolt.fill")
                        }
                        else {
                            ProgressView()
                        }
                    }
                }
            }
            .tabViewStyle(.verticalPage)
        }
        .onAppear{
            Task {
                let shouldUpdate =  await schedule.shouldUpdate()
                pubsSchedule = try await schedule.fetchPlaylist(playlist: .regular, forceUpdate: shouldUpdate)
                rankedSchedule = try await schedule.fetchPlaylist(playlist: .ranked, forceUpdate: shouldUpdate)
                LTMSchedule = await schedule.fetchLTMS()
                
            }
        }
    }
}
struct MapView: View {
    @State var schedule : MapSchedule
    @State var map : Map?
    @State var title : String = "Title"
    @State var symbol : String = "gamecontroller.fill"
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Text(map?.mapName() ?? "Map Name")
                            Text(map?.availableTo ?? .now, style: .timer)
                        }
                        .fontWeight(.semibold)
                        .fontDesign(map?.fontStyle() ?? .default)
                        .font(.title2)
                        
                        Spacer()
                        
                    }
                    Spacer()
                    
                }
                VStack {
                    HStack {
                        Capsule()
                            .frame(width: 150, height: 40)
                            .foregroundStyle(Material.regular)
                            .overlay{
                                HStack {
                                    Image(systemName: symbol)
                                    Text(title)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.top, 40)
                    }
                    .ignoresSafeArea(.all)
                    Spacer()
                    
                    HStack {
                        MonogramView(map: schedule.upcomingMaps(at: .now, range: 1...1).first!)
                            .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                        MonogramView(map: schedule.upcomingMaps(at: .now, range: 2...2).first!)
                            .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                    }
                    .padding()
                }
            }
        }
        .onAppear() {
            map = schedule.determineCurrentMap(at: .now)
        }
        .ignoresSafeArea(.all)
        .background(schedule.determineCurrentMap(at: .now).mapColorTX().gradient)
    }
}

struct MonogramView: View {
    @State var map : Map
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(map.mapColorTX().gradient)
            Text(map.mapName())
                .fontWeight(.semibold)
                .fontDesign(map.fontStyle())
                .multilineTextAlignment(.center)
                .font(.caption)
        }
    }
}

#Preview {
    ContentView()
}
