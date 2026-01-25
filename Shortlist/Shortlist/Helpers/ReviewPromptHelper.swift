//
//  ReviewPromptHelper.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/24/26.
//

import StoreKit
import UIKit

/// Helper class for requesting App Store reviews using AppStore
class ReviewPromptHelper {
    
    /// Requests a review prompt using AppStore
    /// This will show the native iOS review prompt if the system allows it
    /// Note: The system may not show the prompt if the user has been prompted recently
    static func requestReview() {
        // Request review on the main thread
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                AppStore.requestReview(in: windowScene)
            }
        }
    }
    
    /// Opens the App Store page for the app directly
    /// Use this as a fallback when SKStoreReviewController doesn't show
    static func openAppStorePage() {
        guard let appID = Bundle.main.infoDictionary?["AppStoreID"] as? String,
              let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") else {
            // Fallback to generic App Store search
            if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String,
               let encodedName = appName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://apps.apple.com/search?term=\(encodedName)") {
                UIApplication.shared.open(url)
            }
            return
        }
        UIApplication.shared.open(url)
    }
}
