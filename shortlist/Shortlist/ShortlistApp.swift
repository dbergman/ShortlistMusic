//
//  ShortlistApp.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

@main
struct ShortlistApp: App {
    init() {
        UINavigationBar.appearance().tintColor = UIColor.systemOrange
    }

    var body: some Scene {
        WindowGroup {
            ShortlistCollectionsView()
        }
    }
}
