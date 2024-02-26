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
                    } else if let savedRecord = savedRecord, let shortlist = Shortlist(with: savedRecord) {
                        completion(shortlist)
                    }
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
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.editShortlistError = error.localizedDescription
                    }
                }
            }
            
            CKContainer.default().publicCloudDatabase.add(modifyRecords)
        }
        
        private func foundError(error: String) {
            DispatchQueue.main.async {
                self.editShortlistError = error
            }
        }
    }
}

