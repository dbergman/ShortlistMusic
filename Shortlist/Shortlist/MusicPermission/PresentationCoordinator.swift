//
//  PresentationCoordinator.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/31/22.
//

import MusicKit
import Foundation
import SwiftUI

@MainActor
class PresentationCoordinator: ObservableObject {
    static let shared = PresentationCoordinator()
    
    @Published var isOnboardingViewPresented: Bool = false
    @Published var musicAuthorizationStatus: MusicAuthorization.Status = .notDetermined
    
    private var authorizationTask: Task<Void, Never>?
    
    private init() {
        // Initial setup
        Task {
            await checkAuthorizationStatus()
        }
        
        // Monitor app lifecycle changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        authorizationTask?.cancel()
    }
    
    @objc private func appDidBecomeActive() {
        // Check authorization status when app becomes active
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    func checkAuthorizationStatus() async {
        // Cancel any existing task
        authorizationTask?.cancel()
        
        authorizationTask = Task {
            // Check current status
            let currentStatus = await MusicAuthorization.currentStatus
            
            // Update on main thread
            await MainActor.run {
                self.musicAuthorizationStatus = currentStatus
                self.isOnboardingViewPresented = (currentStatus != .authorized)
            }
        }
    }
    
    func requestAuthorization() async {
        // Cancel any existing task
        authorizationTask?.cancel()
        
        authorizationTask = Task {
            // Request authorization
            let newStatus = await MusicAuthorization.request()
            
            // Update on main thread
            await MainActor.run {
                self.musicAuthorizationStatus = newStatus
                self.isOnboardingViewPresented = (newStatus != .authorized)
            }
        }
    }
}
