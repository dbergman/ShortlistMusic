//
//  ShortlistApp.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

@main
struct ShortlistApp: App {
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchView()
                    .onAppear {
                        // Show launch screen for 1.8 seconds (0.3s delay + 1s animation + 0.5s text), then transition to main app
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                ShortlistCollectionsView()
            }
        }
    }
}
