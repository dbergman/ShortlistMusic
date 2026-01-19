//
//  AlbumDetailViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/26/22.
//

import CloudKit
import Foundation
import MusicKit
import UIKit

extension AlbumDetailView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var album: Content?
        @Published var isloading = true
        @Published var isAddingToShortlist = false
        @Published var isRemovingFromShortlist = false
        @Published var showToast = false
        @Published var toastMessage = ""
        @Published var toastType: ToastView.ToastType = .success
        let shortlist: Shortlist
        private var currentShortlistAlbums: [ShortlistAlbum]?
        private let screenSize: CGFloat
        
        init(album: Content?, shortlist: Shortlist, screenSize: CGFloat) {
            self.album = album
            self.shortlist = shortlist
            self.screenSize = screenSize
        }

        func loadTracks(for album: Album, recordID: CKRecord.ID? = nil) async {
            // First, create basic album content with available data (fast)
            let basicDetails = Content(
                id: album.id.rawValue,
                artist: album.artistName,
                artworkURL: album.artwork?.url(width: Int(screenSize), height: Int(screenSize)),
                title: album.title,
                upc: album.upc,
                releaseYear: album.releaseYear,
                appleAlbumURL: album.url,
                spotifyAlbumSearchDeeplink: URL(string: "spotify://search/\(album.title)"),
                recordID: recordID,
                trackDetails: [] // Will be populated below
            )
            
            // Show basic album info immediately
            self.album = basicDetails
            isloading = false
            
            // Log analytics for album viewed
            AnalyticsManager.shared.logAlbumViewed(
                albumTitle: album.title,
                artist: album.artistName
            )
            AnalyticsManager.shared.logScreenView(
                screenName: "Album Detail",
                screenClass: "AlbumDetailView"
            )
            
            // Load tracks and CloudKit albums in parallel (non-blocking)
            async let detailedAlbumTask = album.with([.artists, .tracks])
            async let cloudKitAlbumsTask = loadShortlistAlbums()
            
            // Wait for tracks (needed for display)
            if let detailedAlbum = try? await detailedAlbumTask,
               let albumTracks = detailedAlbum.tracks {
                let theTracks = albumTracks.map { Content.TrackDetails(title: $0.title, duration: $0.displayDuration) }
                
                // Update with track details
                let updatedDetails = Content(
                    id: basicDetails.id,
                    artist: basicDetails.artist,
                    artworkURL: basicDetails.artworkURL,
                    title: basicDetails.title,
                    upc: basicDetails.upc,
                    releaseYear: basicDetails.releaseYear,
                    appleAlbumURL: basicDetails.appleAlbumURL,
                    spotifyAlbumSearchDeeplink: basicDetails.spotifyAlbumSearchDeeplink,
                    recordID: basicDetails.recordID,
                    trackDetails: theTracks
                )
                
                self.album = updatedDetails
            }
            
            // CloudKit albums loaded in background (for add/remove functionality)
            currentShortlistAlbums = await cloudKitAlbumsTask
        }
        
        private func loadShortlistAlbums() async -> [ShortlistAlbum]? {
            return await withCheckedContinuation { continuation in
                CloudKitManager.shared.updateShortlistAlbums(
                    shortlistID: shortlist.id,
                    action: .load
                ) { result in
                    switch result {
                    case .success(let albums):
                        continuation.resume(returning: albums)
                    case .failure(let error):
                        print("Error: \(error)")
                        continuation.resume(returning: nil)
                    }
                }
            }
        }

        
        func getAlbum(shortListAlbum: ShortlistAlbum, shortlist: Shortlist) async {
            // Create basic content immediately from ShortlistAlbum data (fast)
            let basicDetails = Content(
                id: shortListAlbum.id,
                artist: shortListAlbum.artist,
                artworkURL: URL(string: shortListAlbum.artworkURLString),
                title: shortListAlbum.title,
                upc: nil,
                releaseYear: nil,
                appleAlbumURL: nil,
                spotifyAlbumSearchDeeplink: URL(string: "spotify://search/\(shortListAlbum.title)"),
                recordID: shortListAlbum.recordID,
                trackDetails: []
            )
            
            // Show basic album info immediately
            self.album = basicDetails
            isloading = false
            
            // Log analytics for album viewed
            AnalyticsManager.shared.logAlbumViewed(
                albumTitle: shortListAlbum.title,
                artist: shortListAlbum.artist
            )
            AnalyticsManager.shared.logScreenView(
                screenName: "Album Detail",
                screenClass: "AlbumDetailView"
            )
            
            // Load full album details in background
            let request = MusicCatalogResourceRequest<Album>(
                matching: \.id,
                memberOf: [MusicItemID(stringLiteral: shortListAlbum.id)]
            )
            
            let response = try? await request.response()
            
            if let album = response?.items.first {
                await loadTracks(for: album, recordID: shortListAlbum.recordID)
            }
        }
        
        func addAlbumToShortlist() async {
            guard let album = album else { return }
            
            isAddingToShortlist = true
            
            // Ensure we have current albums loaded
            if currentShortlistAlbums == nil {
                currentShortlistAlbums = await loadShortlistAlbums()
            }
            
            let currentAlbumCount = currentShortlistAlbums?.count ?? 0
            
            currentShortlistAlbums = await withCheckedContinuation { continuation in
                CloudKitManager.shared.addAlbumToShortlist(
                    album: album,
                    shortlist: shortlist,
                    currentAlbumCount: currentAlbumCount
                ) { result in
                    switch result {
                    case .success(let albums):
                        continuation.resume(returning: albums)
                    case .failure(let error):
                        print("Error: \(error)")
                        continuation.resume(returning: nil)
                    }
                }
            }
            
            // Check if the operation was successful
            if currentShortlistAlbums != nil {
                // Log analytics for album added
                AnalyticsManager.shared.logAlbumAdded(
                    albumTitle: album.title,
                    artist: album.artist,
                    shortlistId: shortlist.id
                )
                
                // Show success toast
                toastMessage = "Added '\(album.title)' to '\(shortlist.name)'"
                toastType = .success
                showToast = true
                
                // Auto-hide toast after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showToast = false
                }
            } else {
                // Show error toast
                toastMessage = "Failed to add album to shortlist"
                toastType = .error
                showToast = true
                
                // Auto-hide toast after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showToast = false
                }
            }
            
            isAddingToShortlist = false
        }
        
        func removeAlbumFromShortlist() async {
            guard let recordID = album?.recordID, let albumTitle = album?.title else { return }
            
            isRemovingFromShortlist = true
            
            // Ensure we have current albums loaded
            if currentShortlistAlbums == nil {
                currentShortlistAlbums = await loadShortlistAlbums()
            }
            
            currentShortlistAlbums = await withCheckedContinuation { continuation in
                CloudKitManager.shared.removeAlbumFromShortlist(
                    recordID: recordID,
                    shortlist: shortlist
                ) { result in
                    switch result {
                    case .success(let albums):
                        continuation.resume(returning: albums)
                    case .failure(let error):
                        print("Error: \(error)")
                        continuation.resume(returning: nil)
                    }
                }
            }
            
            // Update ranking after successful removal
            if currentShortlistAlbums != nil {
                // Log analytics for album removed
                if let artist = album?.artist {
                    AnalyticsManager.shared.logAlbumRemoved(
                        albumTitle: albumTitle,
                        artist: artist,
                        shortlistId: shortlist.id
                    )
                }
                
                // Hide loading overlay first
                isRemovingFromShortlist = false
                
                // Show success toast
                toastMessage = "Removed '\(albumTitle)' from '\(shortlist.name)'"
                toastType = .success
                showToast = true
                
                // Auto-hide toast after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showToast = false
                }
                
                // Update ranking in background (don't block toast display)
                await updateShortlistAlbumRanking()
            } else {
                // Hide loading overlay first
                isRemovingFromShortlist = false
                
                // Show error toast
                toastMessage = "Failed to remove album from shortlist"
                toastType = .error
                showToast = true
                
                // Auto-hide toast after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showToast = false
                }
            }
        }
        
        func updateShortlistAlbumRanking() async {
            guard let currentShortlistAlbums = currentShortlistAlbums else { 
                print("No current shortlist albums to update ranking")
                return 
            }
            
            // Sort albums by their current rank to maintain order
            let sortedAlbums = currentShortlistAlbums.sorted { $0.rank < $1.rank }
            
            // Create new albums with proper sequential ranking (1, 2, 3, ...)
            let reRankedAlbums = sortedAlbums.enumerated().map { index, album in
                ShortlistAlbum(shortlistAlbum: album, rank: index + 1)
            }
            
            await withCheckedContinuation { continuation in
                CloudKitManager.shared.updateAlbumRanking(albums: reRankedAlbums) { result in
                    switch result {
                    case .success:
                        // Update the local albums array with the new rankings
                        self.currentShortlistAlbums = reRankedAlbums
                        print("Successfully updated album ranking")
                    case .failure(let error):
                        print("Error updating album ranking: \(error)")
                    }
                    continuation.resume()
                }
            }
        }
        
        func isAlbumOnShortlist() async -> Bool {
            // Load albums if not already loaded
            if currentShortlistAlbums == nil {
                currentShortlistAlbums = await loadShortlistAlbums()
            }
            return currentShortlistAlbums?.contains { $0.id == self.album?.id } == true
        }
        
        func isSpotifyInstalled() -> Bool {
            guard let url = URL(string: "spotify://") else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }
}
