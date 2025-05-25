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





#Preview {
    ContentView()
}
