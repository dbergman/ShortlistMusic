//
//  ShortlistCollectionsViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/5/23.
//

import CloudKit
import Foundation

extension ShortlistCollectionsView {
    class ViewModel: ObservableObject {
        @Published var shortlists: [Shortlist] = []
        @Published var isloading = true
        
        init(shortlists: [Shortlist] = []) {
            self.shortlists = shortlists
        }
        
        func getShortlists() throws {
            CKContainer.default().fetchUserRecordID { id, error in
                guard let recordName = id?.recordName else { return }
                
                let dispatchGroup = DispatchGroup()
                var createdShortlists = [Shortlist]()
                
                let shortlistPredicate = NSPredicate(format: "creatorUserRecordID = %@", CKRecord.ID(recordName: recordName))
                let shortlistQuery = CKQuery(recordType: "Shortlists", predicate: shortlistPredicate)
                
                CKContainer.default().publicCloudDatabase.fetch(withQuery: shortlistQuery) { shortlistRecords in
                    do {
                        let records = try shortlistRecords.get()
                        let shortlists = records.matchResults
                            .compactMap { _, result in try? result.get() }
                            .compactMap { Shortlist(with: $0) }
                        
                        for shortlist in shortlists {
                            let predicate = NSPredicate(format: "shortlistId == %@", shortlist.id)
                            let albumQuery = CKQuery(recordType: "Albums", predicate: predicate)
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
                                    print("ERROR")
                                }
                            }
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            self.isloading = false
                            self.shortlists = createdShortlists
                            self.shortlists = createdShortlists.sorted { shortlist1, shortlist2 in
                                if shortlist1.year != shortlist2.year {
                                    return shortlist1.year < shortlist2.year
                                } else {
                                    return shortlist1.createdTimestamp < shortlist2.createdTimestamp
                                }
                            }
                            
                        }
                        
                    } catch {
                        print("ERROR")
                    }
                }
            }
        }
        
        func remove(shortlist: Shortlist) {
            CKContainer.default().publicCloudDatabase.delete(withRecordID: shortlist.recordID) { _, error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.shortlists.removeAll(where: { $0.recordID == shortlist.recordID })
                    }
                } else {
                    print("ERROR")
                }
            }
        }
    }
}
