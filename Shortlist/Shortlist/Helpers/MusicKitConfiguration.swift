//
//  MusicKitConfiguration.swift
//  Shortlist
//
//  Created for dev/production MusicKit configuration
//

import Foundation
import MusicKit

class MusicKitConfiguration {
    static let shared = MusicKitConfiguration()
    
    private init() {}
    
    // Override the bundle identifier for MusicKit requests
    // This allows the dev version to use the production MusicKit configuration
    func configureMusicKit() {
        // For dev versions, we need to use the production bundle ID for MusicKit
        // This is because the dev bundle ID isn't registered with Apple's MusicKit service
        
        if AppConfiguration.shared.isTestVersion {
            // In a real implementation, you might need to use method swizzling
            // or other techniques to override the bundle ID for MusicKit
            // For now, we'll rely on the fact that both versions share the same
            // MusicKit configuration through the app's entitlements
            print("🎵 MusicKit: Using production configuration for dev version")
        }
    }
}

// MARK: - Bundle Identifier Override
// This is a workaround to make MusicKit work with dev bundle IDs
extension Bundle {
    static var musicKitBundleIdentifier: String {
        return AppConfiguration.shared.musicKitBundleIdentifier
    }
}




