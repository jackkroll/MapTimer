//
//  QuickViewWatch.swift
//  QuickViewWatch
//
//  Created by Jack Kroll on 5/25/25.
//

import WidgetKit
import SwiftUI
/*
 struct Provider: AppIntentTimelineProvider {
 func placeholder(in context: Context) -> SimpleEntry {
 SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
 }
 
 func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
 SimpleEntry(date: Date(), configuration: configuration)
 }
 
 func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
 var entries: [SimpleEntry] = []
 
 // Generate a timeline consisting of five entries an hour apart, starting from the current date.
 let currentDate = Date()
 for hourOffset in 0 ..< 5 {
 let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
 let entry = SimpleEntry(date: entryDate, configuration: configuration)
 entries.append(entry)
 }
 
 return Timeline(entries: entries, policy: .atEnd)
 }
 
 func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
 // Create an array with all the preconfigured widgets to show.
 [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
 }
 
 //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
 //        // Generate a list containing the contexts this widget is relevant in.
 //    }
 }
 */
struct Provider: AppIntentTimelineProvider {
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
    }
    
    @State var playlist: Playlist
    
    func placeholder(in context: Context) -> SimpleEntry {
        //let schedule = CurrentMapRotation().fetchPlaylist(playlist: playlist)
        //let map = schedule.determineCurrentMap(at: .now)
        //let upcoming = schedule.upcomingMaps(at: .now, range: 1...2)
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), map: Map(name: .KC, availableAt: Date(timeIntervalSinceNow: -300), availableTo: Date(timeIntervalSinceNow: 3000)), schedule: [])
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        var schedule: MapSchedule
        do {
            schedule = try await CurrentMapRotation().fetchPlaylist(playlist: playlist)
        }
        catch {
            return SimpleEntry(date: .now, configuration: configuration, map: nil, schedule: [])
        }
        let map = schedule.determineCurrentMap(at: .now)
        let upcoming = schedule.upcomingMaps(at: .now, range: 1...2)
        return SimpleEntry(date: Date(), configuration: configuration, map: map, schedule: upcoming)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        var schedule: MapSchedule
        do {
            schedule = try await CurrentMapRotation().fetchPlaylist(playlist: playlist)
        }
        catch {
            //issues, fetch again after 15m
            return Timeline(entries: [], policy: .after(.now + (60 * 15)))
        }
        for rotation in 0...5 {
            let map = schedule.determineCurrentMap(at: .now + Double(rotation) * schedule.rotationInterval)
            
            let entry = SimpleEntry(date: map.availableAt, configuration: configuration, map: map, schedule: schedule.upcomingMaps(at: map.availableAt, range: 1...2))
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let map: Map?
    let schedule: [Map]
}


struct QuickViewWatchEntryView : View {
    @Environment(\.widgetFamily) var family
    @Environment(\.widgetRenderingMode) var renderingMode
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack {
                VStack {
                    Text(entry.map?.mapName() ?? "Map Name")
                        .fontDesign(entry.map?.fontStyle() ?? .default)
                        .fontWeight(.semibold)
                    (Text("until ") + Text(entry.map?.availableTo ?? .now, style: .time))
                }
                .foregroundStyle(entry.map?.mapColorTX().gradient ?? Color.white.gradient)
                if entry.schedule.count > 0 {
                    Divider()
                    HStack {
                        ForEach(entry.schedule, id: \.availableAt) { map in
                            Text(map.mapName())
                                .foregroundStyle(map.mapColorTX().gradient)
                        }
                    }
                    .font(.callout)
                }
            }
            .multilineTextAlignment(.center)
        case .accessoryCorner:
            VStack {
                Text(entry.map?.availableTo ?? .now, style: .time)
                    .font(.system(size: 10))
                    .widgetCurvesContent()
                    .widgetLabel(entry.map?.mapName() ?? "Map Name")
            }
            .tint(.red)
            
        case .accessoryCircular:
            ZStack {
                if renderingMode == .fullColor {
                    Circle()
                        .foregroundStyle(entry.map?.mapColorTX().gradient ?? Color.white.gradient)
                }
                else {
                    Circle()
                        .stroke(lineWidth: 5)
                }
                Text(entry.map?.monogram() ?? "MN")
                    .fontWeight(.semibold)
                    .font(.largeTitle)
            }
            
        case .accessoryInline:
            Text(entry.map?.mapName() ?? "Map Name") + Text(" until ") + Text(entry.map?.availableTo ?? .now, style: .time)
            
            
            
        default:
            Text("Hello, World!")
        }
        
    }
    
}

@main
struct QuickViewWatch: Widget {
    let kind: String = "QuickViewWatch"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider(playlist: .regular)) { entry in
            QuickViewWatchEntryView(entry: entry)
            //.containerBackground(.fill.tertiary, for: .widget)
            .containerBackground(entry.map?.mapColorTX().gradient ?? Color.white.gradient, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
    QuickViewWatch()
} timeline: {
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .KC, availableAt: .now, availableTo: .now + 160), schedule: [Map(name: .BM, availableAt: .now, availableTo: .now + 160), Map(name: .ED, availableAt: .now, availableTo: .now + 160 )])
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .WE, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .OL, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .SP, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .BM, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .ED, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    
}
