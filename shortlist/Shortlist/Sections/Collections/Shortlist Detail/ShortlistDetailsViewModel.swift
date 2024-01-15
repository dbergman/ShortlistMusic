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
            for (index, album) in sortedAlbums.enumerated() {
                await buildAlbumRecord(from: album, updatedRank: index + 1)
            }
            
            getAlbums(for: shortlist)
        }
        
        private func buildAlbumRecord(from shortlistAlbum: ShortlistAlbum?, updatedRank: Int) async {
            guard let album = shortlistAlbum else { return }
            
            await withCheckedContinuation { continuation in
                CKContainer.default().publicCloudDatabase.fetch(withRecordID: album.recordID) { recordToSave, _ in
                    if let recordToSave {
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
    }
}
