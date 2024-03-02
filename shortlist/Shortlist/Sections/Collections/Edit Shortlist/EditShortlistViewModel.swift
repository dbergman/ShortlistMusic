//
//  EditShortlistViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 2/24/24.
//

import CloudKit
import Foundation

extension EditShortlistView {
    class ViewModel: ObservableObject {
        typealias Completion = (Shortlist) -> Void
        @Published var editShortlistError = ""
        
        func updateNewShortlist(shortlist: Shortlist, updatedName: String, updatedYear: String, completion: @escaping Completion) {
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: shortlist.recordID) { record, error in
                guard let record = record else {
                    if let error = error {
                        DispatchQueue.main.async {
                            self.editShortlistError = error.localizedDescription
                        }
                    } else {
                        print("Shortlist record not found")
                    }
                    return
                }
                
                record["name"] = updatedName
                record["year"] = updatedYear
                
                CKContainer.default().publicCloudDatabase.save(record) { savedRecord, saveError in
                    if let saveError = saveError {
                        DispatchQueue.main.async {
                            self.editShortlistError = saveError.localizedDescription
                        }
                    } else if 
                        let savedRecord = savedRecord, 
                        let savedShortlist = Shortlist(with: savedRecord)
                    {
                        let updatedShortlist = Shortlist(shortlist: savedShortlist, shortlistAlbums: shortlist.albums ?? [])
                        completion(updatedShortlist)
                    }
                }
            }
        }
    }
}

