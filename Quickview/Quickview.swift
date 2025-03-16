//
//  Quickview.swift
//  Quickview
//
//  Created by Jack Kroll on 3/10/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let schedule = MapSchedule()
    func placeholder(in context: Context) -> SimpleEntry {
        let map = schedule.determineCurrentMap(at: .now)
        let schedule = schedule.upcomingMaps(at: .now)
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), map: map, schedule: schedule)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let map = schedule.determineCurrentMap(at: .now)
        let schedule = schedule.upcomingMaps(at: .now)
        return SimpleEntry(date: Date(), configuration: configuration, map: map, schedule: schedule)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let mapSchedule = schedule.upcomingMaps(at: .now)
        

        for rotation in 0...5 {
            let map = schedule.determineCurrentMap(at: .now + Double(rotation) * schedule.rotationInterval)
            
            let entry = SimpleEntry(date: map.availableAt, configuration: configuration, map: map, schedule: schedule.upcomingMaps(at: map.availableAt))
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
                        Text(map.mapName())
                            .foregroundStyle(colorScheme == .light ? .white : .black)
                            .fontWeight(.semibold)
                            .fontDesign(map.fontStyle())
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
        Gauge(value: entry.map?.percentComplete() ?? 0) {
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
            Text(entry.map?.mapName() ?? "No Map") + Text(" untill ") + Text(entry.map!.availableTo, style: .time)
        }
    }
}

struct QuickviewEntryView : View {
    
    @Environment(\.widgetFamily) var family

    var entry: Provider.Entry

    var body: some View {
        if family == .accessoryCircular {
            Quickview_AccessoryCircular(entry: entry)
        }
        if family == .accessoryInline {
            Quickview_AccessoryInline(entry: entry)
        }
        
        if family == .systemMedium {
            HStack {
                Quickview_Small(entry: entry)
                Futureview_Small(entry: entry)
            }
        }
        
        if (family == .systemSmall) {
            Quickview_Small(entry: entry)
        }
    }
}

struct Quickview: Widget {
    let kind: String = "Quickview"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            QuickviewEntryView(entry: entry)
                .containerBackground(.fill.secondary, for: .widget)
        }
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
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .KC, availableAt: .now, availableTo: .now + 160), schedule: [Map(name: .WE, availableAt: .now, availableTo: .now + 160), Map(name: .ED, availableAt: .now, availableTo: .now + 160)])
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .WE, availableAt: .distantFuture, availableTo: .distantFuture), schedule: [])
}
