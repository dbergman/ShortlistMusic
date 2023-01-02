//
//  PresentationCoordinator.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/31/22.
//

import MusicKit
import Foundation

class PresentationCoordinator: ObservableObject {
    static let shared = PresentationCoordinator()
    @Published var isOnboardingViewPresented: Bool
    
    private init() {
        let authorizationStatus = MusicAuthorization.currentStatus
        musicAuthorizationStatus = authorizationStatus
        isOnboardingViewPresented = (authorizationStatus != .authorized)
    }
    
    @Published var musicAuthorizationStatus: MusicAuthorization.Status {
        didSet {
            isOnboardingViewPresented = (musicAuthorizationStatus != .authorized)
        }
    }
}
