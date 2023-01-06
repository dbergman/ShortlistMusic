//
//  CreateShortlistViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/4/23.
//

import CloudKit
import Foundation

extension CreateShortlistView {
    class ViewModel: ObservableObject {
        private typealias GetUserIdCompletion = (String) -> Void
        typealias Completion = () -> Void
        
        @Published var createShortlistError = ""

        func addNewShortlist(name: String, year: String, completion: @escaping Completion) {
            getUserID { userId in
                let record = CKRecord(recordType: "Shortlists")

                record.setValue(UUID().uuidString, forKey: "id")
                record.setValue(name, forKey: "name")
                record.setValue(year, forKey: "year")
                record.setValue(userId, forKey: "userId")

                CKContainer.default().publicCloudDatabase.save(record) { savedRecord, error in
                    if error != nil {
                        self.foundError(error: "Unable to save")
                    } else {
                        completion()
                    }
                }
            }
        }
        
        private func getUserID(completion: @escaping GetUserIdCompletion) {
            CKContainer.default().fetchUserRecordID { recordID, error in
                guard
                    error == nil,
                    let userId = recordID?.recordName
                else {
                    self.foundError(error: "Error finding User Record.")
                    return
                }

                completion(userId)
            }
        }
        
        private func foundError(error: String) {
            DispatchQueue.main.async {
                self.createShortlistError = error
            }
        }
    }
}
