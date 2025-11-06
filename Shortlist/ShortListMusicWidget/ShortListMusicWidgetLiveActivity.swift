//
//  ShortListMusicWidgetLiveActivity.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ShortListMusicWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ShortListMusicWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShortListMusicWidgetAttributes.self) { context in
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

extension ShortListMusicWidgetAttributes {
    fileprivate static var preview: ShortListMusicWidgetAttributes {
        ShortListMusicWidgetAttributes(name: "World")
    }
}

extension ShortListMusicWidgetAttributes.ContentState {
    fileprivate static var smiley: ShortListMusicWidgetAttributes.ContentState {
        ShortListMusicWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ShortListMusicWidgetAttributes.ContentState {
         ShortListMusicWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ShortListMusicWidgetAttributes.preview) {
   ShortListMusicWidgetLiveActivity()
} contentStates: {
    ShortListMusicWidgetAttributes.ContentState.smiley
    ShortListMusicWidgetAttributes.ContentState.starEyes
}
