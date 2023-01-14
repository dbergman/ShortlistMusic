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
        typealias GetShortlistsCompletion = ([String]) -> Void
        
        @Published var shortlists: [String] = []
        func getShortlists() throws {
            CKContainer.default().fetchUserRecordID { id, error in
                let pred = NSPredicate(format: "creatorUserRecordID = %@", CKRecord.ID(recordName: id!.recordName))
                let query = CKQuery(recordType: "Shortlists", predicate: pred)

                CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { results in
                    do {
                        let records = try results.get()
                        let shortlists = records.matchResults
                            .compactMap { _, result in try? result.get() }
                            .compactMap { $0["name"] as? String }
                        
                        DispatchQueue.main.async {
                            self.shortlists = shortlists
                        }
                        
                    } catch {
                        
                    }
                }
            }
        }
        
        func removeShortList() {
            
        }
    }
}
