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
            
            do {
                let shortlists = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Shortlist], Error>) in
                    CloudKitManager.shared.getShortlists(ordering: orderToUse) { result in
                        switch result {
                        case .success(let shortlists):
                            continuation.resume(returning: shortlists)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                await MainActor.run {
                    self.isloading = false
                    self.shortlists = shortlists
                    self.currentOrdering = orderToUse
                }
            } catch {
                await MainActor.run {
                    self.isloading = false
                }
                throw error
            }
        }

        func remove(shortlist: Shortlist) async throws {
            do {
                let shortlists = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Shortlist], Error>) in
                    CloudKitManager.shared.remove(shortlist: shortlist) { result in
                        switch result {
                        case .success(let shortlists):
                            continuation.resume(returning: shortlists)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                await MainActor.run {
                    self.shortlists = shortlists
                }
            } catch {
                throw error
            }
        }
    }
}
