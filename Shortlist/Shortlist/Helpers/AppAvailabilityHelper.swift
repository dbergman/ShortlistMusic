//
//  AppAvailabilityHelper.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/24/26.
//

import UIKit

/// Helper class for checking if third-party apps are installed on the device
class AppAvailabilityHelper {
    
    // MARK: - Spotify
    
    /// Checks if Spotify app is installed on the device
    static func isSpotifyInstalled() -> Bool {
        guard let url = URL(string: "spotify://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
