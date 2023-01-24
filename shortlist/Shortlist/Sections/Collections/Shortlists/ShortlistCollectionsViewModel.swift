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
        @Published var shortlists: [Shortlist] = [] {
            didSet {
                print("dustin didSet shortlists count: \(shortlists.count)")
            }
        }
        
        init(shortlists: [Shortlist] = []) {
            self.shortlists = shortlists
        }

        func getShortlists() throws {
            CKContainer.default().fetchUserRecordID { id, error in
                let predicate = NSPredicate(format: "creatorUserRecordID = %@", CKRecord.ID(recordName: id!.recordName))
                let query = CKQuery(recordType: "Shortlists", predicate: predicate)

                CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { results in
                    do {
                        let records = try results.get()

                        let shortlists = records.matchResults
                            .compactMap { _, result in try? result.get() }
                            .compactMap { Shortlist(with: $0) }
                        
                        DispatchQueue.main.async {
                            self.shortlists = shortlists
                            print("Dustin sL count: \(self.shortlists.count)")
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
