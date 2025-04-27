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

    @Parameter(title: "Display the next two maps", default: true)
    var displayFuture: Bool
     
}
