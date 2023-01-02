//
//  MusicPermission.swift
//  Shortlist
//
//  Created by Dustin Bergman on 11/6/22.
//

import Foundation
import MusicKit

class MusicPermission: ObservableObject {
    static let shared = MusicPermission()
    @Published var musicPermissionAccepted = false
    
    func requestMusicKitAuthorization() async {
        let status = await MusicAuthorization.request()

        switch status {
        case MusicAuthorization.Status.authorized:
            musicPermissionAccepted = true
        case MusicAuthorization.Status.restricted:
            musicPermissionAccepted = false
        case MusicAuthorization.Status.denied :
            musicPermissionAccepted = false
        default:
            break
        }
    }
}
