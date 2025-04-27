//
//  Quickview.swift
//  Quickview
//
//  Created by Jack Kroll on 3/10/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
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
/*
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}*/

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let map: Map?
    let schedule: [Map]
}

struct Futureview_Small : View {
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry
    
    var body: some View {
        VStack{
            ForEach(entry.schedule, id: \.availableAt){ map in
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(map.mapColorTX().gradient)
                    .overlay {
                        VStack {
                            Text(map.mapName())
                        }
                        .multilineTextAlignment(.center)
                        .foregroundStyle(colorScheme == .light ? .white : .black)
                        .fontWeight(.semibold)
                        .fontDesign(map.fontStyle())
                    }
            }
        }
    }
}

struct Quickview_Large : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geo in
            VStack {
                Quickview_Small(entry: entry)
                    .frame(height: geo.size.height * (entry.configuration.displayFuture ? 0.5 : 1))
                if (entry.configuration.displayFuture) {
                    ForEach(entry.schedule, id: \.availableAt){ map in
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(map.mapColorTX().gradient)
                            .overlay {
                                HStack {
                                    Text(map.mapName()) + Text(" at ") + Text(map.availableAt, style: .time)
                                }
                                .multilineTextAlignment(.center)
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                                .fontWeight(.semibold)
                                .fontDesign(map.fontStyle())
                            }
                    }
                }
            }
        }
    }
}

struct Quickview_Small: View {
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Spacer()
            Text(entry.map?.mapName() ?? "No Map")
                .font(.title3)
                .fontWeight(.semibold)
            Text("until")
                .font(.title3)
                .fontWeight(.semibold)
            if (entry.map?.availableTo != nil) {
                HStack{
                    Spacer()
                    Text(entry.map!.availableTo, style: .time)
                        .font(.system(size: 500, weight: .semibold))
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
            Spacer()
            
        }
        .fontDesign(entry.map?.fontStyle() ?? .default)
        .foregroundStyle(showsBackground ? (entry.map!.mapColorTX().gradient) : Color.white.gradient)
    }
}

struct Quickview_AccessoryCircular : View {
    var entry: Provider.Entry
    
    var body: some View {
        Gauge(value: 1 - (entry.map?.percentComplete() ?? 1)) {
            Text(entry.map?.mapName() ?? "No Map")
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

struct Quickview_AccessoryInline : View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack{
            Text(entry.map?.mapName() ?? "No Map") + Text(" | ") + Text(entry.map!.availableTo, style: .time)
        }
        
    }
}

struct Quickview_AccessoryRectangular : View {
    var entry: Provider.Entry
    
    var body: some View {
        Gauge(value: 1 - (entry.map?.percentComplete() ?? 1)) {
            Text(entry.map?.mapName() ?? "No Map") + Text(" until ") + Text(entry.map!.availableTo, style: .time)
        }
        .gaugeStyle(.accessoryLinearCapacity)
    }
}

struct QuickviewEntryView : View {
    
    @Environment(\.widgetFamily) var family

    var entry: Provider.Entry

    var body: some View {
        /*
        if family == .accessoryCircular {
            Quickview_AccessoryCircular(entry: entry)
        } */
        if family == .accessoryInline {
            Quickview_AccessoryInline(entry: entry)
        }
        /*
        if family == .accessoryRectangular {
            Quickview_AccessoryRectangular(entry: entry)
        } */
        
        if family == .systemMedium {
            HStack {
                Quickview_Small(entry: entry)
                if (entry.configuration.displayFuture) {
                    Futureview_Small(entry: entry)
                }
            }
        }
        
        if family == .systemLarge {
            Quickview_Large(entry: entry)
        }
        
        if (family == .systemSmall) {
            Quickview_Small(entry: entry)
        }
    }
}

struct Quickview: Widget {
    let kind: String = "Casual Rotation"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider(playlist: .regular)) { entry in
            QuickviewEntryView(entry: entry)
                .containerBackground(.fill.secondary, for: .widget)
        }
#if os(watchOS)
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline])
#else
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium, .systemLarge])
        
#endif
        .configurationDisplayName("Casual Rotation")
    }
}

struct Quickview_Ranked: Widget {
    let kind: String = "Ranked Rotation"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider(playlist: .ranked)) { entry in
            QuickviewEntryView(entry: entry)
                .containerBackground(.fill.secondary, for: .widget)
        }
#if os(watchOS)
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline])
#else
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium, .systemLarge])
#endif
        .configurationDisplayName("Ranked Rotation")
    }
}


/*
extension ConfigurationAppIntent {
    fileprivate static var KC: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.mapName = "Kings Canyon"
        intent.availableUntil = Date.now + 3600
        return intent
    }
    
    fileprivate static var WE: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.mapName = "Worlds Edge"
        intent.availableUntil = Date.now + 3600

        return intent
    }
}*/
//.systemSmall
#Preview(as: .systemMedium) {
    Quickview()
    
} timeline: {
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .KC, availableAt: .now, availableTo: .now + 160), schedule: [Map(name: .WE, availableAt: .now, availableTo: .now + 160), Map(name: .ED, availableAt: .now, availableTo: .now + 160 )])
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .WE, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .OL, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .SP, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .BM, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .ED, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])

}
