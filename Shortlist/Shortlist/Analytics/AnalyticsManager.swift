//
//  AnalyticsManager.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/3/25.
//

import Foundation
import FirebaseAnalytics

/// Centralized analytics manager for Firebase Analytics
/// Provides easy-to-use methods for tracking user events and app usage
struct AnalyticsManager {
    
    // MARK: - Singleton
    
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Core Event Logging
    
    /// Log a custom event with optional parameters
    ///
    /// - Parameters:
    ///   - eventName: The name of the event (use snake_case, e.g., "album_viewed")
    ///   - parameters: Optional dictionary of parameters
    ///                 - Keys should be strings (max 40 characters)
    ///                 - Values should be strings or numbers (max 100 characters for strings)
    ///                 - Maximum 25 parameters per event
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logEvent("button_tapped", parameters: [
    ///     "button_name": "create_shortlist",
    ///     "screen": "collections"
    /// ])
    /// ```
    func logEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        #if DEBUG
        print("📊 Analytics Event: \(eventName)")
        if let parameters = parameters {
            print("   Parameters: \(parameters)")
        }
        #endif
        
        Analytics.logEvent(eventName, parameters: parameters)
    }
    
    // MARK: - Standard Firebase Events
    
    /// Log when a screen is viewed
    ///
    /// - Parameters:
    ///   - screenName: The name of the screen being viewed
    ///   - screenClass: Optional class name of the screen (e.g., "ShortlistDetailsView")
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logScreenView(
    ///     screenName: "Shortlist Detail",
    ///     screenClass: "ShortlistDetailsView"
    /// )
    /// ```
    func logScreenView(screenName: String, screenClass: String? = nil) {
        var parameters: [String: Any] = [
            AnalyticsParameterScreenName: screenName
        ]
        if let screenClass = screenClass {
            parameters[AnalyticsParameterScreenClass] = screenClass
        }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }
    
    /// Log when a user performs a search
    ///
    /// - Parameter searchTerm: The search query entered by the user
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logSearch(searchTerm: "The Beatles")
    /// ```
    func logSearch(searchTerm: String) {
        Analytics.logEvent(AnalyticsEventSearch, parameters: [
            AnalyticsParameterSearchTerm: searchTerm
        ])
    }
    
    /// Log when content is selected
    ///
    /// - Parameters:
    ///   - contentType: The type of content selected (e.g., "album", "shortlist")
    ///   - itemId: Optional unique identifier for the selected item
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logSelectContent(
    ///     contentType: "album",
    ///     itemId: "album_123"
    /// )
    /// ```
    func logSelectContent(contentType: String, itemId: String? = nil) {
        var parameters: [String: Any] = [
            AnalyticsParameterContentType: contentType
        ]
        if let itemId = itemId {
            parameters[AnalyticsParameterItemID] = itemId
        }
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: parameters)
    }
    
    // MARK: - Shortlist Events
    
    /// Log when a new shortlist is created
    ///
    /// - Parameters:
    ///   - shortlistName: The name of the shortlist
    ///   - year: The year associated with the shortlist
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logShortlistCreated(
    ///     shortlistName: "Best of 2024",
    ///     year: 2024
    /// )
    /// ```
    func logShortlistCreated(shortlistName: String, year: Int) {
        logEvent("shortlist_created", parameters: [
            "shortlist_name": shortlistName,
            "year": year
        ])
    }
    
    /// Log when a shortlist is edited
    ///
    /// - Parameter shortlistId: The unique identifier of the shortlist
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logShortlistEdited(shortlistId: "shortlist_123")
    /// ```
    func logShortlistEdited(shortlistId: String) {
        logEvent("shortlist_edited", parameters: [
            "shortlist_id": shortlistId
        ])
    }
    
    /// Log when a shortlist is deleted
    ///
    /// - Parameter shortlistId: The unique identifier of the shortlist
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logShortlistDeleted(shortlistId: "shortlist_123")
    /// ```
    func logShortlistDeleted(shortlistId: String) {
        logEvent("shortlist_deleted", parameters: [
            "shortlist_id": shortlistId
        ])
    }
    
    /// Log when a shortlist is viewed
    ///
    /// - Parameters:
    ///   - shortlistId: The unique identifier of the shortlist
    ///   - shortlistName: Optional name of the shortlist
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logShortlistViewed(
    ///     shortlistId: "shortlist_123",
    ///     shortlistName: "Best of 2024"
    /// )
    /// ```
    func logShortlistViewed(shortlistId: String, shortlistName: String? = nil) {
        var parameters: [String: Any] = [
            "shortlist_id": shortlistId
        ]
        if let shortlistName = shortlistName {
            parameters["shortlist_name"] = shortlistName
        }
        logEvent("shortlist_viewed", parameters: parameters)
    }
    
    /// Log when a shortlist is shared
    ///
    /// - Parameters:
    ///   - shortlistId: The unique identifier of the shortlist
    ///   - method: The sharing method used (e.g., "airdrop", "copy_link", "image")
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logShortlistShared(
    ///     shortlistId: "shortlist_123",
    ///     method: "airdrop"
    /// )
    /// ```
    func logShortlistShared(shortlistId: String, method: String) {
        logEvent("shortlist_shared", parameters: [
            "shortlist_id": shortlistId,
            "share_method": method
        ])
    }
    
    // MARK: - Album Events
    
    /// Log when an album is added to a shortlist
    ///
    /// - Parameters:
    ///   - albumTitle: The title of the album
    ///   - artist: The artist name
    ///   - shortlistId: Optional identifier of the shortlist it was added to
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logAlbumAdded(
    ///     albumTitle: "Abbey Road",
    ///     artist: "The Beatles",
    ///     shortlistId: "shortlist_123"
    /// )
    /// ```
    func logAlbumAdded(albumTitle: String, artist: String, shortlistId: String? = nil) {
        var parameters: [String: Any] = [
            "album_title": albumTitle,
            "artist": artist
        ]
        if let shortlistId = shortlistId {
            parameters["shortlist_id"] = shortlistId
        }
        logEvent("album_added", parameters: parameters)
    }
    
    /// Log when an album is removed from a shortlist
    ///
    /// - Parameters:
    ///   - albumTitle: The title of the album
    ///   - artist: The artist name
    ///   - shortlistId: The identifier of the shortlist it was removed from
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logAlbumRemoved(
    ///     albumTitle: "Abbey Road",
    ///     artist: "The Beatles",
    ///     shortlistId: "shortlist_123"
    /// )
    /// ```
    func logAlbumRemoved(albumTitle: String, artist: String, shortlistId: String) {
        logEvent("album_removed", parameters: [
            "album_title": albumTitle,
            "artist": artist,
            "shortlist_id": shortlistId
        ])
    }
    
    /// Log when an album is viewed
    ///
    /// - Parameters:
    ///   - albumTitle: The title of the album
    ///   - artist: The artist name
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logAlbumViewed(
    ///     albumTitle: "Abbey Road",
    ///     artist: "The Beatles"
    /// )
    /// ```
    func logAlbumViewed(albumTitle: String, artist: String) {
        logEvent("album_viewed", parameters: [
            "album_title": albumTitle,
            "artist": artist
        ])
    }
    
    /// Log when an album is opened in a music service
    ///
    /// - Parameters:
    ///   - albumTitle: The title of the album
    ///   - artist: The artist name
    ///   - service: The music service used (e.g., "spotify", "apple_music")
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logAlbumOpenedInService(
    ///     albumTitle: "Abbey Road",
    ///     artist: "The Beatles",
    ///     service: "spotify"
    /// )
    /// ```
    func logAlbumOpenedInService(albumTitle: String, artist: String, service: String) {
        logEvent("album_opened_in_service", parameters: [
            "album_title": albumTitle,
            "artist": artist,
            "service": service
        ])
    }
    
    // MARK: - Search Events
    
    /// Log when a user searches for albums
    ///
    /// - Parameter searchTerm: The search query
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logAlbumSearch(searchTerm: "The Beatles")
    /// ```
    func logAlbumSearch(searchTerm: String) {
        logEvent("album_search", parameters: [
            "search_term": searchTerm
        ])
    }
    
    /// Log when a user searches for artists
    ///
    /// - Parameter searchTerm: The search query
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logArtistSearch(searchTerm: "The Beatles")
    /// ```
    func logArtistSearch(searchTerm: String) {
        logEvent("artist_search", parameters: [
            "search_term": searchTerm
        ])
    }
    
    // MARK: - Widget Events
    
    /// Log when a widget is tapped
    ///
    /// - Parameter widgetType: The type of widget (e.g., "shortlist_widget", "album_widget")
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.logWidgetTapped(widgetType: "shortlist_widget")
    /// ```
    func logWidgetTapped(widgetType: String) {
        logEvent("widget_tapped", parameters: [
            "widget_type": widgetType
        ])
    }
    
    // MARK: - User Properties
    
    /// Set a user property that will be associated with all subsequent events
    ///
    /// - Parameters:
    ///   - value: The value of the property (nil to remove the property)
    ///   - name: The name of the property (max 24 characters, alphanumeric + underscore)
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.setUserProperty(
    ///     value: "premium",
    ///     forName: "subscription_tier"
    /// )
    /// ```
    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    /// Set the user ID for analytics (use carefully, consider privacy)
    ///
    /// - Parameter userId: The user identifier (nil to clear)
    ///
    /// **Privacy Note:** Only set user ID if you have explicit user consent
    /// and it's necessary for your analytics needs.
    ///
    /// Example:
    /// ```swift
    /// AnalyticsManager.shared.setUserId("user_123")
    /// ```
    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }
}
