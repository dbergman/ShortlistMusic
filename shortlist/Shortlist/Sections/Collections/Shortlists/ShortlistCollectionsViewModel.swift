//
//  ShortlistCollectionsViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/5/23.
//

import Foundation

extension ShortlistCollectionsView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var shortlists: [Shortlist] = []
        @Published var isloading = true
        
        init(shortlists: [Shortlist] = []) {
            self.shortlists = shortlists
        }

        func getShortlists() async throws {
             let shortlists = try await withCheckedThrowingContinuation { continuation in
                CloudKitManager.shared.getShortlists { result in
                    switch result {
                    case .success(let shortlists):
                        continuation.resume(returning: shortlists)

                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            isloading = false
            self.shortlists = shortlists
        }

        func remove(shortlist: Shortlist) async throws {
            let shortlists = try await withCheckedThrowingContinuation { continuation in
                CloudKitManager.shared.remove(shortlist: shortlist, completion: { result in
                   switch result {
                   case .success(let shortlists):
                       continuation.resume(returning: shortlists)

                   case .failure(let error):
                       continuation.resume(throwing: error)
                   }
               })
            }

            self.shortlists = shortlists            
        }
    }
}
