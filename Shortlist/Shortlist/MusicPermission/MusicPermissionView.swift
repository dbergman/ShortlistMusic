//
//  MusicPermissionView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/30/22.
//

import MusicKit
import SwiftUI

struct MusicPermissionView: View {
    @Binding var musicAuthorizationStatus: MusicAuthorization.Status

    var body: some View {
        VStack(alignment: .center) {
            Text("Please grant Music Albums access to ")
                + Text(Image(systemName: "applelogo")) + Text(" Music in Settings.")
            Button("Enable AppleMusic") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        }.padding(75)
    }

    fileprivate struct SheetPresentationModifier: ViewModifier {
        @StateObject private var presentationCoordinator = PresentationCoordinator.shared
        
        func body(content: Content) -> some View {
            content
                .sheet(isPresented: $presentationCoordinator.isOnboardingViewPresented) {
                    MusicPermissionView(musicAuthorizationStatus: $presentationCoordinator.musicAuthorizationStatus)
                        .interactiveDismissDisabled()
                }
        }
    }
}

extension View {
    func onBoardingSheet() -> some View {
        modifier(MusicPermissionView.SheetPresentationModifier())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPermissionView(musicAuthorizationStatus: .constant(.notDetermined))
    }
}
