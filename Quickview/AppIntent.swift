//
//  AppIntent.swift
//  Quickview
//
//  Created by Jack Kroll on 3/10/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var mapName: String
    @Parameter(title: "Available Until", default: Date.distantFuture)
    var availableUntil: Date?
}
