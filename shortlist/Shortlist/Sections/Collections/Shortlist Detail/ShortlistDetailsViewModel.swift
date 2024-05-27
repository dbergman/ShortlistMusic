//
//  ShortlistDetailsViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/29/23.
//

import Foundation

extension ShortlistDetailsView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var shortlist: Shortlist
        
        init(shortlist: Shortlist) {
            self.shortlist = shortlist
        }
        
        func getAlbums(for shortlist: Shortlist) async throws {
            self.shortlist = try await withCheckedThrowingContinuation { continuation in
                CloudKitManager.shared.getAlbums(for: shortlist, completion: { result in
                    switch result {
                    case .success(let shortlist):
                        continuation.resume(returning: shortlist)
                        
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                })
            }
        }
        
        func updateShortlistAlbumRanking(sortedAlbums: [ShortlistAlbum]) async throws {
            try await withCheckedThrowingContinuation { continuation in
                CloudKitManager.shared.updateAlbumRanking(
                    for: shortlist,
                    sortedAlbums: sortedAlbums
                ) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                        
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
