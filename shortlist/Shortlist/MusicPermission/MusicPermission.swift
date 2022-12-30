//
//  MusicPermission.swift
//  Shortlist
//
//  Created by Dustin Bergman on 11/6/22.
//

import Combine
import Foundation

class MusicPermission: ObservableObject {
    static let shared = MusicPermission()
    
    /// Observer of changes to the current MusicKit authorization status.
    private var musicAuthorizationStatusObserver: AnyCancellable?
    
    /// Begins observing MusicKit authorization status.
    func beginObservingMusicAuthorizationStatus() {
        musicAuthorizationStatusObserver = MusicPermissionView.PresentationCoordinator.shared.$musicAuthorizationStatus
            .filter { authorizationStatus in
                return (authorizationStatus == .authorized)
            }
            .sink { _ in }
    }
}
