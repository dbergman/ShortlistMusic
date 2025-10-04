//
//  AppConfiguration.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/3/25.
//

import Foundation

struct AppConfiguration {
    static let shared = AppConfiguration()
    
    // App identification
    let bundleIdentifier: String
    let appName: String
    let isTestVersion: Bool
    
    private init() {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.bundleIdentifier = bundleId
        
        // Check for dev version by bundle ID or environment variable
        let isDevByBundleId = bundleId.contains(".dev") || bundleId.contains(".test")
        let isDevByEnvironment = ProcessInfo.processInfo.environment["IS_DEV_VERSION"] == "YES"
        
        self.isTestVersion = isDevByBundleId || isDevByEnvironment
        
        if isTestVersion {
            self.appName = "Shortlist Dev"
        } else {
            self.appName = "Shortlist"
        }
    }
    
    // You can add other configuration differences here
    var shouldShowDebugInfo: Bool {
        return isTestVersion
    }
    
    var cloudKitContainerIdentifier: String {
        // For now, use the same CloudKit container for both versions
        // TODO: Create separate CloudKit container for dev version in Apple Developer Console
        return "iCloud.com.dus.shortList"
    }
    
    var musicKitBundleIdentifier: String {
        // Use the production bundle ID for MusicKit to avoid registration issues
        return "com.dus.shortList"
    }
}
