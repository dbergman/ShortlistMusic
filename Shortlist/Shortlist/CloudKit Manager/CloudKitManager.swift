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
