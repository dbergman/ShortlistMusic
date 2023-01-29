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
        @Published var albums: [ShortListAlbum] = []
        
        func getAlbums(for shortlist: Shortlist) {
            let predicate = NSPredicate(format: "shortlistId == %@", shortlist.id)
            let query = CKQuery(recordType: "Albums", predicate: predicate)
            
            CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { results in
                do {
                    let records = try results.get()
                    
                    print("dustin:\(records)")

                    let albums = records.matchResults
                        .compactMap { _, result in try? result.get() }
                        .compactMap { ShortListAlbum(with: $0) }
                    
                    print("")

                    DispatchQueue.main.async {
                        self.albums = albums
                        print("Dustin albums count: \(self.albums.count)")
                    }
                    
                } catch {
                    print("ERROR")
                }
            }
        }
    }
}
