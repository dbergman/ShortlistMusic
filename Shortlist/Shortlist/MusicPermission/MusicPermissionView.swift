//
//  MusicPermissionView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/30/22.
//

import MusicKit
import SwiftUI

struct MusicPermissionView: View {
    @StateObject private var coordinator = PresentationCoordinator.shared
    @State private var isRequestingPermission = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("ShortListMusic")
                .font(Theme.shared.avenir(size: 32, weight: .bold))
                .fontWeight(.bold)

            // Status-based message
            Group {
                if coordinator.musicAuthorizationStatus != .authorized && coordinator.iCloudStatus != .available {
                    Text("ShortListMusic needs access to Apple Music and iCloud to work properly.")
                        .font(Theme.shared.avenir(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.gray)
                } else if coordinator.musicAuthorizationStatus != .authorized {
                    Text("ShortListMusic needs access to Apple Music to work properly.")
                        .font(Theme.shared.avenir(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.gray)
                } else if coordinator.iCloudStatus != .available {
                    Text("ShortListMusic needs iCloud access to sync your shortlists.")
                        .font(Theme.shared.avenir(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.gray)
                } else {
                    Text("Checking permissions...")
                        .font(Theme.shared.avenir(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.gray)
                }
            }

            // Action buttons
            VStack(spacing: 12) {
                // Request permission button (only show for notDetermined music)
                if coordinator.musicAuthorizationStatus == .notDetermined {
                    Button(action: {
                        isRequestingPermission = true
                        Task {
                            await coordinator.requestAuthorization()
                            isRequestingPermission = false
                        }
                    }) {
                        HStack {
                            if isRequestingPermission {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text(isRequestingPermission ? "Requesting..." : "Grant Music Access")
                                .font(Theme.shared.avenir(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isRequestingPermission)
                    }
                }
                
                // iCloud login button (show when iCloud is not available)
                if coordinator.iCloudStatus != .available {
                    Button(action: {
                        if let url = URL(string: "App-prefs:APPLE_ID") {
                            UIApplication.shared.open(url)
                        } else if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "icloud")
                            Text("Sign in to iCloud")
                                .font(Theme.shared.avenir(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                // Settings button (show for denied/restricted music or iCloud issues)
                if coordinator.musicAuthorizationStatus == .denied || coordinator.musicAuthorizationStatus == .restricted || coordinator.iCloudStatus == .unavailable {
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
                        .background(Color.primary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                // Refresh button (show for all states)
                Button(action: {
                    Task {
                        await coordinator.checkAuthorizationStatus()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Status")
                            .font(Theme.shared.avenir(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding()
        .onAppear {
            // Check status when view appears
            Task {
                await coordinator.checkAuthorizationStatus()
            }
        }
    }

    fileprivate struct SheetPresentationModifier: ViewModifier {
        @StateObject private var presentationCoordinator = PresentationCoordinator.shared
        
        func body(content: Content) -> some View {
            content
                .sheet(isPresented: $presentationCoordinator.isOnboardingViewPresented) {
                    MusicPermissionView()
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
        MusicPermissionView()
    }
}
