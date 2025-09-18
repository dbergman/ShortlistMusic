//
//  UserDefaultsManager.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/5/23.
//

import Foundation

/// A wrapper class for UserDefaults to provide type-safe access to persisted user preferences
/// This class can be extended to add more persistence features in the future
class UserDefaultsManager {
    
    // MARK: - Singleton
    static let shared = UserDefaultsManager()
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let shortlistSortOrder = "shortlist_sort_order"
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Shortlist Sort Order
    /// The current sort order for shortlists
    var shortlistSortOrder: ShortlistOrdering {
        get {
            let rawValue = userDefaults.string(forKey: Keys.shortlistSortOrder) ?? ShortlistOrdering.yearDescending.rawValue
            return ShortlistOrdering(rawValue: rawValue) ?? .yearDescending
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.shortlistSortOrder)
        }
    }
    
    // MARK: - Future Extensibility
    // Add more persistence methods here as needed:
    // - var userTheme: Theme
    // - var lastSyncDate: Date
    // - var userPreferences: UserPreferences
    // etc.
}
