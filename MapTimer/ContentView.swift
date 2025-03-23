//
//  ContentView.swift
//  MapTimer
//
//  Created by Jack Kroll on 3/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var positionID :Int? = 0
    @State private var scrollOffset : CGPoint = .zero
    @State private var schedule = CurrentMapRotation()
    var body: some View {
        GeometryReader { geo in
            VStack{
                TabView{
                    Tab("Casual", systemImage: "gamecontroller.fill") {
                        VStack {
                            MapScheduleView(schedule: schedule.fetchPlaylist(playlist: .regular))
                        }
                    }
                    if (!schedule.fetchLTM().isEmpty) {
                        Tab("LTM", systemImage: "arcade.stick") {
                            VStack{
                                Text("yeah")
                            }
                        }
                    }
                    Tab("Ranked", systemImage: "bolt.fill") {
                        VStack{
                            MapScheduleView(schedule: schedule.fetchPlaylist(playlist: .ranked))
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
    @State var map: Map? = nil
    
    var body : some View {
        GeometryReader { geo in
            
            VStack {
                VStack {
                    Text(map?.mapName() ?? "Unknown Map")
                    Text(map?.availableTo ?? .now, style: .timer)
                }
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .fontWeight(.semibold)
                .font(.largeTitle)
                .fontDesign(map?.fontStyle())
                .onAppear() {
                    map = schedule.determineCurrentMap(at: .now)
                }
                .padding()
                .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.55)
                .background{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(map?.mapColorTX().gradient ?? Color.gray.gradient)
                        
                }
                
                Divider().frame(width: geo.size.width * 0.9)
                ForEach(schedule.upcomingMaps(at: .now, range: 1...schedule.rotation.count), id: \.availableTo) { map in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(map.mapColorTX().gradient)
                        .padding(.horizontal,20)
                        .overlay{
                            VStack{
                                Text(map.mapName())
                                Text(map.availableTo, style: schedule.rotationInterval > 43200 ? .date : .time)
                            }
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                            .fontWeight(.semibold)
                            .font(.title2)
                            .fontDesign(map.fontStyle())
                        }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        
    }
}

#Preview {
    ContentView()
}
