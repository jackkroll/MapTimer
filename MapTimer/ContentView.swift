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
    @State private var schedule = MapSchedule()
    @State private var map : Map? = nil
    @State private var upcoming : [Map] = []
    var body: some View {
        GeometryReader { geo in
            VStack{
                TabView{
                    Tab("Current", systemImage: "clock") {
                        VStack{
                            Text(map?.mapName() ?? "Unknown")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            if map?.description != nil{
                                Text(map!.description ?? "No description")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            Text(map?.availableTo ?? Date.now, style:.timer)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                        }
                        .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.85)
                        .background(RoundedRectangle(cornerRadius: 20).stroke(.blue.gradient, lineWidth: 5))
                        .id(1)
                        .padding()
                    }
                    Tab("Upcoming", systemImage: "list.clipboard") {
                        VStack{
                            ForEach(upcoming, id: \.availableAt) { map in
                                Text(map.mapName())
                            }
                        }
                    }

                    
                }
            }
            .onAppear(){
                map = schedule.determineCurrentMap(at: .now)
                upcoming = schedule.upcomingMaps(at:.now)
                DispatchQueue.main.asyncAfter(deadline: .now() + map!.availableTo.timeIntervalSinceNow) {
                    
                    map = schedule.determineCurrentMap(at: .now)
                    upcoming = schedule.upcomingMaps(at:.now)
                }
            }
        }
    }
}



#Preview {
    ContentView()
}
