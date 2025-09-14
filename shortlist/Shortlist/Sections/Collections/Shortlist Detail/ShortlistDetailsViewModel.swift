//
//  ShortlistDetailsViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/29/23.
//

import UIKit

extension ShortlistDetailsView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var shortlist: Shortlist
        @Published var isLoading = false
        
        init(shortlist: Shortlist) {
            self.shortlist = shortlist
        }
        
        func getAlbums(for shortlist: Shortlist) async throws {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let updatedShortlist = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Shortlist, Error>) in
                    CloudKitManager.shared.getAlbums(for: shortlist, completion: { result in
                        switch result {
                        case .success(let shortlist):
                            continuation.resume(returning: shortlist)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    })
                }
                
                await MainActor.run {
                    self.shortlist = updatedShortlist
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                throw error
            }
        }
        
        func updateShortlistAlbumRanking(sortedAlbums: [ShortlistAlbum]) async throws {
            do {
                let updatedShortlist = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Shortlist, Error>) in
                    CloudKitManager.shared.updateAlbumRanking(
                        for: shortlist,
                        sortedAlbums: sortedAlbums
                    ) { result in
                        switch result {
                        case .success(let shortlist):
                            continuation.resume(returning: shortlist)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                await MainActor.run {
                    self.shortlist = updatedShortlist
                }
            } catch {
                throw error
            }
        }
    }
}
