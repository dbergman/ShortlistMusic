//
//  ShortlistApp.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

@main
struct ShortlistApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ShortlistCollectionsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
