//
//  QuickviewLiveActivity.swift
//  Quickview
//
//  Created by Jack Kroll on 3/10/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct QuickviewAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct QuickviewLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QuickviewAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension QuickviewAttributes {
    fileprivate static var preview: QuickviewAttributes {
        QuickviewAttributes(name: "World")
    }
}

extension QuickviewAttributes.ContentState {
    fileprivate static var smiley: QuickviewAttributes.ContentState {
        QuickviewAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: QuickviewAttributes.ContentState {
         QuickviewAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: QuickviewAttributes.preview) {
   QuickviewLiveActivity()
} contentStates: {
    QuickviewAttributes.ContentState.smiley
    QuickviewAttributes.ContentState.starEyes
}
