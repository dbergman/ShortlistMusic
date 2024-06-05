//
//  CloudKitManager.swift
//  Shortlist
//
//  Created by Dustin Bergman on 5/24/24.
//

import CloudKit
import Foundation

class CloudKitManager {
    static let shared: CloudKitManager = {
        let instance = CloudKitManager()
        
        return instance
    }()
}

// Create Shortlist
extension CloudKitManager {
    func addNewShortlist(name: String, year: String, completion: @escaping (Result<Shortlist, Error>) -> Void) {
        getUserID { result in
            switch result {
            case .success:
                let record = CKRecord(recordType: "Shortlists")
                record.setValue(UUID().uuidString, forKey: "id")
                record.setValue(name, forKey: "name")
                record.setValue(year, forKey: "year")
                
                CKContainer.default().publicCloudDatabase.save(record) { savedRecord, error in
                    if let error {
                        completion(.failure(error))
                    } else if let savedRecord = savedRecord, let shortlist = Shortlist(with: savedRecord) {
                        completion(.success(shortlist))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getUserID(completion: @escaping (Result<String, Error>) -> Void) {
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let error {
                completion(.failure(error))
            } else if let userId = recordID?.recordName {
                completion(.success(userId))
            } else {
                let unknownError = NSError(
                    domain: "com.dus.shortlist",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Error finding User Record."]
                )
                completion(.failure(unknownError))
            }
        }
    }
}

// Shortlist Collection Methods
extension CloudKitManager {
    func getShortlists(completion: @escaping (Result<[Shortlist], Error>) -> Void) {
        CKContainer.default().fetchUserRecordID { id, error in
            guard let recordName = id?.recordName else { return }
            
            let dispatchGroup = DispatchGroup()
            var createdShortlists = [Shortlist]()
            
            let shortlistPredicate = NSPredicate(format: "creatorUserRecordID = %@", CKRecord.ID(recordName: recordName))
            let shortlistQuery = CKQuery(recordType: "Shortlists", predicate: shortlistPredicate)
            
            CKContainer.default().publicCloudDatabase.fetch(withQuery: shortlistQuery) { shortlistRecords in
                do {
                    let records = try shortlistRecords.get()
                    var shortlists = records.matchResults
                        .compactMap { _, result in try? result.get() }
                        .compactMap { Shortlist(with: $0) }
                    
                    for shortlist in shortlists {
                        let predicate = NSPredicate(format: "shortlistId == %@", shortlist.id)
                        let albumQuery = CKQuery(recordType: "Albums", predicate: predicate)
                        albumQuery.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
                        dispatchGroup.enter()
                        
                        CKContainer.default().publicCloudDatabase.fetch(withQuery: albumQuery) { albumRecords in
                            do {
                                let records = try albumRecords.get()
                                
                                let albums = records.matchResults
                                    .compactMap { _, result in try? result.get() }
                                    .compactMap { ShortlistAlbum(with: $0) }
                                createdShortlists.append(Shortlist(shortlist: shortlist, shortlistAlbums: albums))
                                dispatchGroup.leave()
                            } catch {
                                dispatchGroup.leave()
                                completion(.failure(error))
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        shortlists = createdShortlists
                        shortlists = createdShortlists.sorted { shortlist1, shortlist2 in
                            if shortlist1.year != shortlist2.year {
                                return shortlist1.year < shortlist2.year
                            } else {
                                return shortlist1.createdTimestamp < shortlist2.createdTimestamp
                            }
                        }
                        
                        completion(.success(shortlists))
                        
                    }
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func remove(shortlist: Shortlist, completion: @escaping (Result<[Shortlist], Error>) -> Void) {
        CKContainer.default().publicCloudDatabase.delete(withRecordID: shortlist.recordID) { _, error in
            if let error {
                completion(.failure(error))
            } else {
                self.getShortlists(completion: completion)
            }
        }
    }
}

// Shortlist Detail Methods
extension CloudKitManager {
    func getAlbums(for shortlist: Shortlist, completion: @escaping (Result<Shortlist, Error>) -> Void) {
        let predicate = NSPredicate(format: "shortlistId == %@", shortlist.id)
        let query = CKQuery(recordType: "Albums", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        
        CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { results in
            do {
                let records = try results.get()
                
                let albums = records.matchResults
                    .compactMap { _, result in try? result.get() }
                    .compactMap { ShortlistAlbum(with: $0) }
            
                let populatedShortlist = Shortlist(shortlist: shortlist, shortlistAlbums: albums)
                completion(.success(populatedShortlist))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateAlbumRanking(
        for shortlist: Shortlist,
        sortedAlbums: [ShortlistAlbum],
        completion: @escaping (Result<Shortlist, Error>) -> Void)
    {
        let albumRecordIds = sortedAlbums.map { $0.recordID }
        
        let sortedAlbumsWithRank = Task {
            var sortedAlbumsWithRank = [ShortlistAlbum]()
            for (rankIndex, album) in sortedAlbums.enumerated() {
                let shortlistAlbum = ShortlistAlbum(shortlistAlbum: album, rank: rankIndex + 1)
                sortedAlbumsWithRank.append(shortlistAlbum)
            }
            
            return sortedAlbumsWithRank
        }
        
        let saveCompletion: ([CKRecord]) -> Void = { recordsToSave in
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
                
                saveCompletion(recordsToSave)

                Task {
                    let updatedShortlist = try await Shortlist(shortlist: shortlist, shortlistAlbums: sortedAlbumsWithRank.result.get())
                    completion(.success(updatedShortlist))
                }
 
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func updateRecords(recordsToSave: [CKRecord]) async {
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
