//
//  ShortlistApp.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI
import UIKit
import MusicKit
import FirebaseCore

@main
struct ShortlistApp: App {
    @State private var showLaunchScreen = true
    @State private var isLookingUpMusicKit = false
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        #if DEBUG
        // Enable debug mode for Firebase Analytics during development
        // This allows you to see events in real-time in Firebase Console
        // Remove this in production or wrap in DEBUG flag
        print("🔥 Firebase initialized successfully")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
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
                .onOpenURL { url in
                    // Handle URLs from widgets
                    Task {
                        await handleWidgetURL(url)
                    }
                }
                
                if isLookingUpMusicKit {
                    MusicKitLoadingOverlay()
                }
            }
        }
    }
    
    private func handleWidgetURL(_ url: URL) async {
        guard url.scheme == "shortlist" else {
            forwardMusicServiceURL(url)
            return
        }
        
        // Handle "shortlist://open" - just open the app (already open, but this allows widget tap to work)
        if url.host == "open" {
            // Log widget tap analytics
            AnalyticsManager.shared.logWidgetTapped(widgetType: "shortlist_widget")
            return
        }
        
        // Handle "shortlist://album" - open album in music service
        guard url.host == "album" else {
            forwardMusicServiceURL(url)
            return
        }
        
        guard let albumInfo = parseAlbumInfo(from: url) else { return }
        
        // Log widget tap analytics
        AnalyticsManager.shared.logWidgetTapped(widgetType: "album_widget")
        
        let musicService = getCurrentMusicService()
        let musicServiceURL = await generateMusicServiceURL(
            for: albumInfo,
            service: musicService
        )
        
        if let musicURL = musicServiceURL, UIApplication.shared.canOpenURL(musicURL) {
            // Log album opened in service
            AnalyticsManager.shared.logAlbumOpenedInService(
                albumTitle: albumInfo.title,
                artist: albumInfo.artist,
                service: musicService.lowercased().replacingOccurrences(of: " ", with: "_")
            )
            
            await MainActor.run {
                UIApplication.shared.open(musicURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func forwardMusicServiceURL(_ url: URL) {
        let urlString = url.absoluteString
        guard urlString.hasPrefix("spotify://") || urlString.hasPrefix("music://") || urlString.contains("music.apple.com"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        Task { @MainActor in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private struct AlbumInfo {
        let title: String
        let artist: String
        let id: String?
        let appleAlbumURL: String?
    }
    
    private func parseAlbumInfo(from url: URL) -> AlbumInfo? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var title: String?
        var artist: String?
        var albumId: String?
        var appleAlbumURL: String?
        
        for item in queryItems {
            switch item.name {
            case "title": title = item.value
            case "artist": artist = item.value
            case "id": albumId = item.value
            case "appleAlbumURL": appleAlbumURL = item.value
            default: break
            }
        }
        
        guard let albumTitle = title, let albumArtist = artist else {
            return nil
        }
        
        return AlbumInfo(
            title: albumTitle,
            artist: albumArtist,
            id: albumId,
            appleAlbumURL: appleAlbumURL
        )
    }
    
    private func getCurrentMusicService() -> String {
        let rawValue = UserDefaults.standard.string(forKey: "widgetMusicService") ?? "Spotify"
        return rawValue == "Apple Music" ? "Apple Music" : "Spotify"
    }
    
    private func generateMusicServiceURL(for albumInfo: AlbumInfo, service: String) async -> URL? {
        if service == "Apple Music" {
            return await generateAppleMusicURL(for: albumInfo)
        } else {
            return generateSpotifyURL(for: albumInfo)
        }
    }
    
    private func generateAppleMusicURL(for albumInfo: AlbumInfo) async -> URL? {
        await MainActor.run { isLookingUpMusicKit = true }
        defer {
            Task { @MainActor in isLookingUpMusicKit = false }
        }
        
        if let id = albumInfo.id, !id.isEmpty, !id.hasPrefix("preview-") {
            if let url = await queryMusicKitForAlbum(id: id) {
                return url
            }
        }
        
        if let appleURLString = albumInfo.appleAlbumURL, let url = URL(string: appleURLString) {
            return url
        }
        
        if let id = albumInfo.id, !id.isEmpty {
            return URL(string: "music://album/\(id)") ?? URL(string: "https://music.apple.com/album/\(id)")
        }
        
        let searchQuery = "\(albumInfo.title) \(albumInfo.artist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? albumInfo.title
        return URL(string: "music://search?term=\(searchQuery)") ?? URL(string: "https://music.apple.com/search?term=\(searchQuery)")
    }
    
    private func queryMusicKitForAlbum(id: String) async -> URL? {
        do {
            let request = MusicCatalogResourceRequest<Album>(
                matching: \.id,
                memberOf: [MusicItemID(stringLiteral: id)]
            )
            let response = try await request.response()
            return response.items.first?.url
        } catch {
            return nil
        }
    }
    
    private func generateSpotifyURL(for albumInfo: AlbumInfo) -> URL? {
        let searchQuery = "\(albumInfo.title) \(albumInfo.artist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? albumInfo.title
        return URL(string: "spotify://search/\(searchQuery)")
    }
}

