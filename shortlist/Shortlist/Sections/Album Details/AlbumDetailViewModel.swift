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
        private let screenSize: CGFloat
        
        init(screenSize: CGFloat) {
            self.screenSize = screenSize
        }

        func loadTracks(for album: Album, shortlist: Shortlist, recordID: CKRecord.ID? = nil) async {
            let detailedAlbum = try? await album.with([.artists, .tracks])

            guard let albumTracks = detailedAlbum?.tracks else { return }
            
            let theTracks = albumTracks.map { Content.TrackDetails(title: $0.title, duration: $0.displayDuration) }

            let details = Content(
                id: album.id.rawValue,
                artist: album.artistName,
                artworkURL: album.artwork?.url(width: Int(screenSize), height: Int(screenSize)),
                title: album.title,
                upc: album.upc,
                recordID: recordID,
                trackDetails: theTracks)

            DispatchQueue.main.async {
                self.album = details
            }
        }
        
        func getAlbum(shortListAlbum: ShortListAlbum, shortlist: Shortlist) async {
            let request = MusicCatalogResourceRequest<Album>(
                matching: \.id,
                memberOf: [MusicItemID(stringLiteral: shortListAlbum.id)]
            )
    
            let response = try? await request.response()

            if let album =  response?.items.first {
                await loadTracks(for: album, shortlist: shortlist, recordID: shortListAlbum.recordID)
            }
        }
        
        func addAlbumToShortlist(shortlist: Shortlist, album: Content) async {
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
        
        func removeAlbumFromShortlist(album: Content) {
            guard let recordID = album.recordID else { return }

            CKContainer.default().publicCloudDatabase.delete(withRecordID: recordID) { deletedRecord, error in
                if error != nil {
                    print("Unable to delete")
                } else if let deletedRecord = deletedRecord {
                    print("dustin delete \(deletedRecord)")
                }
            }
        }
    }
}
