//
//  AlbumDetailViewModel.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/26/22.
//

import Foundation
import MusicKit

extension AlbumDetailView {
    class ViewModel: ObservableObject {
        @Published var albumDetails: Content?

        func loadTracks(for album: Album, size: CGFloat) async {
            let detailedAlbum = try? await album.with([.artists, .tracks])

            guard let albumTracks = detailedAlbum?.tracks else { return }
            
            let theTracks = albumTracks.map { Content.TrackDetails(title: $0.title, duration: $0.displayDuration) }

            let details = Content(
                artist: album.artistName,
                artworkURL: album.artwork?.url(width: Int(size), height: Int(size)),
                title: album.title,
                trackDetails: theTracks)

            DispatchQueue.main.async {
                self.albumDetails = details
            }
        }
    }
}
