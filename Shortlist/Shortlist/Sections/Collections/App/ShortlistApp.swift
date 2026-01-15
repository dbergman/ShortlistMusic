//
//  ShortlistApp.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI
import UIKit
import MusicKit

@main
struct ShortlistApp: App {
    @State private var showLaunchScreen = true
    @State private var isLookingUpMusicKit = false
    
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
                        MainTabView()
                    }
                }
                .onOpenURL { url in
                    // Handle URLs from widgets
                    Task {
                        await handleWidgetURL(url)
                    }
                }
                
                // Loading indicator overlay for MusicKit lookup
                if isLookingUpMusicKit {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                    
                    VStack(spacing: 20) {
                        SpinningRecordView(size: 80, color: .blue)
                        
                        Text("Opening Apple Music...")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Please wait...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.8))
                            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    )
                    .allowsHitTesting(false)
                }
            }
        }
    }
    
    /// Handles URLs from widgets - checks UserDefaults fresh and opens the correct music service
    private func handleWidgetURL(_ url: URL) async {
        // Check if this is our custom widget URL scheme
        guard url.scheme == "shortlist", url.host == "album" else {
            // If it's already a music service URL, forward it directly
            let urlString = url.absoluteString
            if urlString.hasPrefix("spotify://") || urlString.hasPrefix("music://") || urlString.contains("music.apple.com") {
                if UIApplication.shared.canOpenURL(url) {
                    await MainActor.run {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            return
        }
        
        // Parse album information from URL query parameters
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }
        
        var title: String?
        var artist: String?
        var albumId: String?
        var appleAlbumURL: String?
        
        for item in queryItems {
            switch item.name {
            case "title":
                title = item.value
            case "artist":
                artist = item.value
            case "id":
                albumId = item.value
            case "appleAlbumURL":
                appleAlbumURL = item.value
            default:
                break
            }
        }
        
        guard let albumTitle = title, let albumArtist = artist else {
            return
        }
        
        // Check UserDefaults FRESH every time to get current music service preference
        let musicServiceRawValue = UserDefaults.standard.string(forKey: "widgetMusicService") ?? "Spotify"
        let musicService = musicServiceRawValue == "Apple Music" ? "Apple Music" : "Spotify"
        
        // Generate the correct music service URL based on current preference
        let musicServiceURL: URL?
        
        if musicService == "Apple Music" {
            // Show loading indicator for Apple Music lookup
            await MainActor.run {
                isLookingUpMusicKit = true
            }
            
            // Use defer to ensure loading indicator is always hidden
            defer {
                Task { @MainActor in
                    isLookingUpMusicKit = false
                }
            }
            
            // For Apple Music, try to get the album URL from MusicKit using the album ID
            if let id = albumId, !id.isEmpty, id != "preview-1", id != "preview-2" {
                // Query MusicKit for the album by ID
                do {
                    let request = MusicCatalogResourceRequest<Album>(
                        matching: \.id,
                        memberOf: [MusicItemID(stringLiteral: id)]
                    )
                    let response = try await request.response()
                    
                    // Get the Apple Music URL from the album if found
                    if let album = response.items.first, let albumURL = album.url {
                        musicServiceURL = albumURL
                    } else {
                        // Fallback to stored URL if MusicKit doesn't provide one
                        if let appleURLString = appleAlbumURL, let appleURL = URL(string: appleURLString) {
                            musicServiceURL = appleURL
                        } else {
                            // Fallback to direct album link
                            musicServiceURL = URL(string: "music://album/\(id)") ?? URL(string: "https://music.apple.com/album/\(id)")
                        }
                    }
                } catch {
                    // If MusicKit query fails, fall back to stored URL or direct link
                    if let appleURLString = appleAlbumURL, let appleURL = URL(string: appleURLString) {
                        musicServiceURL = appleURL
                    } else {
                        musicServiceURL = URL(string: "music://album/\(id)") ?? URL(string: "https://music.apple.com/album/\(id)")
                    }
                }
            } else if let appleURLString = appleAlbumURL, let appleURL = URL(string: appleURLString) {
                // Use stored URL if no ID available
                musicServiceURL = appleURL
            } else {
                // Last resort: use search
                let searchQuery = "\(albumTitle) \(albumArtist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? albumTitle
                musicServiceURL = URL(string: "music://search?term=\(searchQuery)") ?? URL(string: "https://music.apple.com/search?term=\(searchQuery)")
            }
        } else {
            // Spotify - no loading indicator needed
            let searchQuery = "\(albumTitle) \(albumArtist)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? albumTitle
            musicServiceURL = URL(string: "spotify://search/\(searchQuery)")
        }
        
        // Open the music service URL immediately
        if let musicURL = musicServiceURL, UIApplication.shared.canOpenURL(musicURL) {
            await MainActor.run {
                UIApplication.shared.open(musicURL, options: [:], completionHandler: nil)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ShortlistCollectionsView()
                .tabItem {
                    Image(systemName: "music.note.list")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                }
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
