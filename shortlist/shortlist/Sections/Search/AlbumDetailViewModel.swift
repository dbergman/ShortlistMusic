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
        @Published var albumDetails: AlbumDetails?

        func loadTracks(for album: Album, size: CGFloat) async {
            let detailedAlbum = try? await album.with([.artists, .tracks])
            
            var theTracks = [AlbumDetails.TrackDetails]()
            
            guard let albumTracks = detailedAlbum?.tracks else { return }
            for track in albumTracks {
                let trackDuration: String
                
                if let duration = track.duration {
                    trackDuration = DateFormatter.durationFormatter.string(from: duration) ?? ""
                } else {
                    trackDuration = ""
                }

                theTracks.append(AlbumDetails.TrackDetails(title: track.title, duration:trackDuration))
            }
            
            let details = AlbumDetails(
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
