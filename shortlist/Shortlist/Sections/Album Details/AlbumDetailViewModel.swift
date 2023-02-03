//
//  AlbumDetailViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/26/22.
//

import CloudKit
import Foundation
import MusicKit

extension AlbumDetailView {
    class ViewModel: ObservableObject {
        @Published var album: Content?
        private let size: CGFloat
        
        init(size: CGFloat) {
            self.size = size
        }

        func loadTracks(for album: Album) async {
            let detailedAlbum = try? await album.with([.artists, .tracks])

            guard let albumTracks = detailedAlbum?.tracks else { return }
            
            let theTracks = albumTracks.map { Content.TrackDetails(title: $0.title, duration: $0.displayDuration) }

            let details = Content(
                id: album.id.rawValue,
                artist: album.artistName,
                artworkURL: album.artwork?.url(width: Int(size), height: Int(size)),
                title: album.title,
                upc: album.upc,
                trackDetails: theTracks)

            DispatchQueue.main.async {
                self.album = details
            }
        }
        
        func getAlbum(albumId: String) async {
            let request = MusicCatalogResourceRequest<Album>(matching: \.id, memberOf: [MusicItemID(stringLiteral: albumId)])
            let response = try? await request.response()

            if let album =  response?.items.first {
                await loadTracks(for: album)
            }
            
            print("")
        }
        
        func addAlbumToShortlist(shortlist: Shortlist, album: Content) {
            let record = CKRecord(recordType: "Albums")
            record.setValue(album.artist, forKey: "artist")
            record.setValue(album.artworkURL?.absoluteString, forKey: "artwork")
            record.setValue(album.id, forKey: "id")
            record.setValue(0, forKey: "rank")
            record.setValue(album.title, forKey: "title")
            record.setValue(album.upc, forKey: "upc")
            record.setValue(shortlist.id, forKey: "shortlistId")
            

            CKContainer.default().publicCloudDatabase.save(record) { savedRecord, error in
                if error != nil {
                    print("Unable to save")
                } else if let savedRecord = savedRecord {
                    print("dustin saved \(savedRecord)")
                }
            }
        }
    }
}
