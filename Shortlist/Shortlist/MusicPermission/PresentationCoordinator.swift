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
    @Published var iCloudStatus: iCloudAccountStatus = .couldNotDetermine
    
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
            let currentMusicStatus = MusicAuthorization.currentStatus
            let currentiCloudStatus = await CloudKitManager.shared.checkiCloudStatus()
            
            // Update on main thread
            await MainActor.run {
                self.musicAuthorizationStatus = currentMusicStatus
                self.iCloudStatus = currentiCloudStatus
                self.isOnboardingViewPresented = (currentMusicStatus != .authorized) || (currentiCloudStatus != .available)
            }
        }
    }
    
    func requestAuthorization() async {
        // Cancel any existing task
        authorizationTask?.cancel()
        
        authorizationTask = Task {
            // Request authorization
            let newMusicStatus = await MusicAuthorization.request()
            let currentiCloudStatus = await CloudKitManager.shared.checkiCloudStatus()
            
            // Update on main thread
            await MainActor.run {
                self.musicAuthorizationStatus = newMusicStatus
                self.iCloudStatus = currentiCloudStatus
                self.isOnboardingViewPresented = (newMusicStatus != .authorized) || (currentiCloudStatus != .available)
            }
        }
    }
}
