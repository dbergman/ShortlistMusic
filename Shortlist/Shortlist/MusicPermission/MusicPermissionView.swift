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
            VStack(spacing: 20) {
                // Music Icon and Title
                HStack(spacing: 8) {
                    Image(systemName: "music.note")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black)

                    Text("ShortListMusic")
                        .font(Theme.shared.avenir(size: 32, weight: .bold))
                        .fontWeight(.bold)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black)
                }

                Text("Please grant ShortListMusic access to Apple Music in Settings.")
                    .font(Theme.shared.avenir(size: 20, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.gray)

                .font(Theme.shared.avenir(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Go to Settings")
                            .font(Theme.shared.avenir(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 4)
            .padding()
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
