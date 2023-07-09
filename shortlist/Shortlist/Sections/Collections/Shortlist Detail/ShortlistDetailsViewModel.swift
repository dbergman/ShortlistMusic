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
            
            CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { results in
                do {
                    let records = try results.get()

                    let albums = records.matchResults
                        .compactMap { _, result in try? result.get() }
                        .compactMap { ShortListAlbum(with: $0) }

                    DispatchQueue.main.async {
                        self.shortlist.albums = albums
                    }
                    
                } catch {
                    print("ERROR")
                }
            }
        }
    }
}
