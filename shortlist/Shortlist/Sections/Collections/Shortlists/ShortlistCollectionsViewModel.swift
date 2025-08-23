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
        @Published var currentOrdering: ShortlistOrdering = .yearDescending
        
        init(shortlists: [Shortlist] = []) {
            self.shortlists = shortlists
        }

        func getShortlists(ordering: ShortlistOrdering? = nil) async throws {
            let orderToUse = ordering ?? currentOrdering
            let shortlists = try await withCheckedThrowingContinuation { continuation in
                CloudKitManager.shared.getShortlists(ordering: orderToUse) { result in
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
            self.currentOrdering = orderToUse
        }

        func remove(shortlist: Shortlist) async throws {
            let shortlists = try await withCheckedThrowingContinuation { continuation in
                CloudKitManager.shared.remove(shortlist: shortlist) { result in
                   switch result {
                   case .success(let shortlists):
                       continuation.resume(returning: shortlists)

                   case .failure(let error):
                       continuation.resume(throwing: error)
                   }
               }
            }

            self.shortlists = shortlists            
        }
    }
}
