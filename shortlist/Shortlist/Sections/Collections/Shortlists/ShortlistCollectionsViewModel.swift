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
        @Published var currentOrdering: ShortlistOrdering {
            didSet {
                UserDefaultsManager.shared.shortlistSortOrder = currentOrdering
            }
        }
        
        init(shortlists: [Shortlist] = []) {
            self.shortlists = shortlists
            self.currentOrdering = UserDefaultsManager.shared.shortlistSortOrder
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
        
        func addShortlist(_ shortlist: Shortlist) {
            var updatedShortlists = shortlists
            updatedShortlists.append(shortlist)
            self.shortlists = sortShortlists(updatedShortlists, by: currentOrdering)
        }
        
        private func sortShortlists(_ shortlists: [Shortlist], by ordering: ShortlistOrdering) -> [Shortlist] {
            switch ordering {
            case .yearAscending:
                return shortlists.sorted { shortlist1, shortlist2 in
                    if shortlist1.year != shortlist2.year {
                        return shortlist1.year < shortlist2.year
                    } else {
                        return shortlist1.createdTimestamp < shortlist2.createdTimestamp
                    }
                }
            case .yearDescending:
                return shortlists.sorted { shortlist1, shortlist2 in
                    if shortlist1.year != shortlist2.year {
                        return shortlist1.year > shortlist2.year
                    } else {
                        return shortlist1.createdTimestamp > shortlist2.createdTimestamp
                    }
                }
            case .creationAscending:
                return shortlists.sorted { shortlist1, shortlist2 in
                    return shortlist1.createdTimestamp < shortlist2.createdTimestamp
                }
            case .creationDescending:
                return shortlists.sorted { shortlist1, shortlist2 in
                    return shortlist1.createdTimestamp > shortlist2.createdTimestamp
                }
            }
        }
    }
}
