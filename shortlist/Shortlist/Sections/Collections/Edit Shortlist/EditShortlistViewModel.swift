//
//  EditShortlistViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 2/24/24.
//

import Foundation

extension EditShortlistView {
    class ViewModel: ObservableObject {
        typealias Completion = (Shortlist) -> Void
        @Published var editShortlistError = ""
        
        func updateNewShortlist(shortlist: Shortlist, updatedName: String, updatedYear: String) async throws -> Shortlist  {
            do {
                let updatedShortlist = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Shortlist, Error>) in
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
                
                await MainActor.run {
                    self.editShortlistError = ""
                }
                
                return updatedShortlist
            } catch {
                await MainActor.run {
                    self.editShortlistError = error.localizedDescription
                }
                throw error
            }
        }
    }
}

