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
        
        func updateNewShortlist(shortlist: Shortlist, updatedName: String, updatedYear: String) async throws -> Shortlist  {
            let shortlist = try await withCheckedThrowingContinuation { continuation in
                CloudKitManager.shared.updateNewShortlist(
                    shortlist: shortlist,
                    updatedName: updatedName,
                    updatedYear: updatedYear) { result in
                        switch result {
                        case .success(let shortlist):
                            continuation.resume(returning: shortlist)
                            
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
            }
            
            return shortlist
        }
    }
}

