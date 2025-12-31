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
            // TODO: Implement lock screen/banner UI
            EmptyView()
        } dynamicIsland: { context in
            DynamicIsland {
                // TODO: Implement expanded UI regions
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                // TODO: Implement compact leading UI
                EmptyView()
            } compactTrailing: {
                // TODO: Implement compact trailing UI
                EmptyView()
            } minimal: {
                // TODO: Implement minimal UI
                EmptyView()
            }
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
