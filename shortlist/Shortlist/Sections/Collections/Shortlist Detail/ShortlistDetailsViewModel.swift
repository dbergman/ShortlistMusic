//
//  ShortlistDetailsViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/29/23.
//

import CloudKit
import Foundation

extension ShortlistDetailsView {
    class ViewModel: ObservableObject {
        @Published var shortlist: Shortlist
        
        init(shortlist: Shortlist) {
            self.shortlist = shortlist
        }
        
        func getAlbums(for shortlist: Shortlist) {
            let predicate = NSPredicate(format: "shortlistId == %@", shortlist.id)
            let query = CKQuery(recordType: "Albums", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
            
            CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { results in
                do {
                    let records = try results.get()
                    
                    let albums = records.matchResults
                        .compactMap { _, result in try? result.get() }
                        .compactMap { ShortlistAlbum(with: $0) }
                    
                    DispatchQueue.main.async {
                        self.shortlist.albums = albums
                    }
                } catch {
                    print("ERROR")
                }
            }
        }
        
        func updateShortlistAlbumRanking(sortedAlbums: [ShortlistAlbum]) async {
            let albumRecordIds = sortedAlbums.map { $0.recordID }
            
            let sortedAlbumsWithRank = Task {
                var sortedAlbumsWithRank = [ShortlistAlbum]()
                for (rankIndex, album) in sortedAlbums.enumerated() {
                    let shortlistAlbum = ShortlistAlbum(shortlistAlbum: album, rank: rankIndex + 1)
                    sortedAlbumsWithRank.append(shortlistAlbum)
                }
                
                return sortedAlbumsWithRank
            }
            
            DispatchQueue.main.async {
                Task {
                    try await self.shortlist = Shortlist(shortlist: self.shortlist, shortlistAlbums: sortedAlbumsWithRank.result.get())
                }
            }
            
            let completion: ([CKRecord]) -> Void = { recordsToSave in
                Task {
                    await self.updateRecords(recordsToSave: recordsToSave)
                }
            }
            
            CKContainer.default().publicCloudDatabase.fetch(withRecordIDs: albumRecordIds) { result in
                var recordsToSave = [CKRecord]()
                
                switch result {
                case .success(let albumDict):
                    for (rankIndex, album) in sortedAlbums.enumerated() {
                        let shortlistAlbumResult = albumDict[album.recordID]
                        
                        if case .success(let shortlistAlbum) = shortlistAlbumResult {
                            shortlistAlbum.setValue(rankIndex + 1, forKey: "rank")
                            recordsToSave.append(shortlistAlbum)
                        }
                    }
                    
                    completion(recordsToSave)
                    
                case .failure:
                    print("ERROR")
                }
            }
        }
        
        func updateRecords(recordsToSave: [CKRecord]) async {
            let modifyRecords = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
            modifyRecords.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
            modifyRecords.qualityOfService = QualityOfService.userInteractive
            modifyRecords.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("dustin Updated")
                    // self.getAlbums(for: self.shortlist)
                case .failure(let error):
                    print(error)
                }
            }
            
            CKContainer.default().publicCloudDatabase.add(modifyRecords)
        }
    }
}
