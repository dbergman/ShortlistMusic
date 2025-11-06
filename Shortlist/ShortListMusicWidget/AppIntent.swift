//
//  AppIntent.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Configure your music widget." }
}
