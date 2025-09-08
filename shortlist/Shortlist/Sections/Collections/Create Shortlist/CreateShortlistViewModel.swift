//
//  CreateShortlistViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/4/23.
//

import Foundation

extension CreateShortlistView {
    class ViewModel: ObservableObject {
        @Published var createShortlistError = ""

        func addNewShortlist(name: String, year: String) async throws -> Shortlist {
            do {
                let shortlist = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Shortlist, Error>) in
                    CloudKitManager.shared.addNewShortlist(
                        name: name, year: year) { result in
                            switch result {
                            case .success(let shortlist):
                                continuation.resume(returning: shortlist)
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                }
                
                await MainActor.run {
                    self.createShortlistError = ""
                }
                
                return shortlist
            } catch {
                await MainActor.run {
                    self.createShortlistError = "Error finding User Record."
                }
                throw error
            }
        }
    }
}
