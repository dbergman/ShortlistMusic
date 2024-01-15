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
        let shortlist: Shortlist
        private var currentShortlistAlbums: [ShortlistAlbum]?
        private let screenSize: CGFloat
        
        init(album: Content?, shortlist: Shortlist, screenSize: CGFloat) {
            self.album = album
            self.shortlist = shortlist
            self.screenSize = screenSize
        }
        
        func loadTracks(for album: Album, recordID: CKRecord.ID? = nil) async {
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
            
            currentShortlistAlbums = await withCheckedContinuation { continuation in
                updateShortlistAlbums(completion: { result in
                    switch result {
                    case .success(let albums):
                        continuation.resume(returning: albums)
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                })
            }
            
            DispatchQueue.main.async {
                self.album = details
            }
        }
        
        func getAlbum(shortListAlbum: ShortlistAlbum, shortlist: Shortlist) async {
            let request = MusicCatalogResourceRequest<Album>(
                matching: \.id,
                memberOf: [MusicItemID(stringLiteral: shortListAlbum.id)]
            )
            
            let response = try? await request.response()
            
            if let album =  response?.items.first {
                await loadTracks(for: album, recordID: shortListAlbum.recordID)
            }
        }
        
        private func updateShortlistAlbums(completion: @escaping (Result<[ShortlistAlbum], Error>) -> Void) {
            let predicate = NSPredicate(format: "shortlistId == %@", shortlist.id)
            let albumQuery = CKQuery(recordType: "Albums", predicate: predicate)
            
            CKContainer.default().publicCloudDatabase.fetch(withQuery: albumQuery) { albumRecords in
                do {
                    let records = try albumRecords.get()
                    
                    let albums = records.matchResults
                        .compactMap { _, result in try? result.get() }
                        .compactMap { ShortlistAlbum(with: $0) }
                    
                    completion(.success(albums))
                    
                    print("dustin album count \(albums.count)")
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        func addAlbumToShortlist() async {
            guard let album = album else { return }
            
            let record = CKRecord(recordType: "Albums")
            record.setValue(album.artist, forKey: "artist")
            if let artworkURLString = album.artworkURL?.absoluteString {
                record.setValue(artworkURLString, forKey: "artwork")
            }
            
            let albumRank: Int
            
            if let count = currentShortlistAlbums?.count {
                albumRank = count + 1
            } else {
                albumRank = 1
            }
            
            print("dustin theRank: \(albumRank)")
            
            record.setValue(album.id, forKey: "id")
            record.setValue(albumRank, forKey: "rank")
            record.setValue(album.title, forKey: "title")
            record.setValue(album.upc, forKey: "upc")
            record.setValue(shortlist.id, forKey: "shortlistId")
            
            do {
                let savedRecord = try await CKContainer.default().publicCloudDatabase.save(record)
                
                print("dustin saved \(album.title)")
                
                currentShortlistAlbums = await withCheckedContinuation { continuation in
                    updateShortlistAlbums(completion: { result in
                        switch result {
                        case .success(let albums):
                            continuation.resume(returning: albums)
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    })
                }
            } catch {
                print("Unable to save")
            }
        }
        
        func removeAlbumFromShortlist() async {
            guard let recordID = album?.recordID else { return }
            
            do {
                let deletedRecord = try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: recordID)
                print("dustin delete \(deletedRecord)")
                
                currentShortlistAlbums = await withCheckedContinuation { continuation in
                    updateShortlistAlbums(completion: { result in
                        switch result {
                        case .success(let albums):
                            continuation.resume(returning: albums)
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    })
                }
                
                await updateShortlistAlbumRanking()
            } catch {
                print("Unable to delete")
            }
        }
        
        func updateShortlistAlbumRanking() async {
            guard let currentShortlistAlbums = currentShortlistAlbums else { return }
            
            for (index, album) in currentShortlistAlbums.enumerated() {
                await buildAlbumRecord(from: album, updatedRank: index + 1)
            }
        }
        
        private func buildAlbumRecord(from shortlistAlbum: ShortlistAlbum?, updatedRank: Int) async {
            guard let album = shortlistAlbum else { return }
            
            await withCheckedContinuation { continuation in
                CKContainer.default().publicCloudDatabase.fetch(withRecordID: album.recordID) { recordToSave, _ in
                    if let recordToSave {
                        print("dustin Updated theRank: \(updatedRank)")
                        
                        recordToSave.setValue(updatedRank, forKey: "rank")
                        
                        let modifyRecords = CKModifyRecordsOperation(recordsToSave:[recordToSave], recordIDsToDelete: nil)
                        modifyRecords.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
                        modifyRecords.qualityOfService = QualityOfService.userInitiated
                        modifyRecords.modifyRecordsResultBlock = { result in
                            switch result {
                            case .success:
                                print("dustin Updated \(album.title)")
                            case .failure(let error):
                                print(error)
                            }
                            
                            continuation.resume()
                        }
                        
                        CKContainer.default().publicCloudDatabase.add(modifyRecords)
                    }
                }
            }
        }
        
        func isAlbumOnShortlist() async -> Bool {
            currentShortlistAlbums?.contains { $0.id == self.album?.id } == true
        }
    }
}
