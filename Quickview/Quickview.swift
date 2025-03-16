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
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), map: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let map = schedule.determineCurrentMap(at: .now)
        return SimpleEntry(date: Date(), configuration: configuration, map: map)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let mapSchedule = schedule.upcomingMaps()

        for rotation in 0...schedule.rotation.count {
            let entry = SimpleEntry(date: mapSchedule[rotation].availableAt, configuration: configuration, map: mapSchedule[rotation])
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
}

struct QuickviewEntryView : View {
    
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        if family == .accessoryCircular || family == .accessoryRectangular{
            Gauge(value: entry.map?.percentComplete() ?? 0) {
                Text(entry.map?.mapName() ?? "No Map")
                    .multilineTextAlignment(.center)
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
        if family == .accessoryInline {
            HStack{
                Text(entry.map?.mapName() ?? "No Map") + Text(" untill ") + Text(entry.map!.availableTo, style: .time)
            }
        }
        
        if (family == .systemSmall) {
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
            .foregroundStyle((entry.map?.mapColorTX() ?? .primary).gradient)
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

#Preview(as: .systemSmall) {
    Quickview()
} timeline: {
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .KC, availableAt: .now, availableTo: .now + 160))
    SimpleEntry(date: .now, configuration: .init(), map: Map(name: .WE, availableAt: .distantFuture, availableTo: .distantFuture))
}
