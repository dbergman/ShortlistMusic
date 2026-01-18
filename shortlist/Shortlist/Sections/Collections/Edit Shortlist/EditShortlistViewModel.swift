//
//  EditShortlistViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 2/24/24.
//

import Foundation
import CloudKit

extension EditShortlistView {
    class ViewModel: ObservableObject {
        typealias Completion = (Shortlist) -> Void
        @Published var editShortlistError = ""
        @Published var isUpdating = false
        
        private var updateTask: Task<Shortlist, Error>?
        
        func updateNewShortlist(shortlist: Shortlist, updatedName: String, updatedYear: String) async throws -> Shortlist  {
            // Cancel any existing update task to prevent race conditions
            updateTask?.cancel()
            
            // Create new update task
            let task = Task<Shortlist, Error> {
                await MainActor.run {
                    self.isUpdating = true
                    self.editShortlistError = ""
                }
                
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
                        self.isUpdating = false
                        self.editShortlistError = ""
                    }
                    
                    return updatedShortlist
                } catch {
                    await MainActor.run {
                        self.isUpdating = false
                        // Provide more specific error messages
                        if let ckError = error as? CKError {
                            switch ckError.code {
                            case .networkUnavailable, .networkFailure:
                                self.editShortlistError = "Network error. Please check your connection and try again."
                            case .notAuthenticated:
                                self.editShortlistError = "Authentication error. Please sign in to iCloud and try again."
                            case .quotaExceeded:
                                self.editShortlistError = "iCloud storage quota exceeded. Please free up space and try again."
                            case .serviceUnavailable:
                                self.editShortlistError = "iCloud service temporarily unavailable. Please try again in a moment."
                            case .requestRateLimited:
                                self.editShortlistError = "Too many requests. Please wait a moment and try again."
                            default:
                                self.editShortlistError = "Failed to update shortlist: \(error.localizedDescription)"
                            }
                        } else {
                            self.editShortlistError = "Failed to update shortlist: \(error.localizedDescription)"
                        }
                    }
                    throw error
                }
            }
            
            updateTask = task
            return try await task.value
        }
    }
}

