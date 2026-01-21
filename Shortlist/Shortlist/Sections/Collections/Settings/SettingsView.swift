//
//  SettingsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/13/26.
//

import SwiftUI
import UIKit
import MessageUI

enum MusicService: String, CaseIterable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    
    var displayName: String {
        return rawValue
    }
    
    var iconName: String {
        switch self {
        case .spotify:
            return "spotify"
        case .appleMusic:
            return "applelogo"
        }
    }
}

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("widgetMusicService") private var selectedMusicService: String = MusicService.spotify.rawValue
    @State private var showingContactMail = false
    
    private var currentMusicService: MusicService {
        MusicService(rawValue: selectedMusicService) ?? .spotify
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    private var contactEmailSubject: String {
        "ShortlistAPP \(appVersion)"
    }
    
    private var contactEmailBody: String {
        "Dear Mr. Shortlist.\n\n"
    }
    
    @ViewBuilder
    private func serviceIcon(for service: MusicService, size: CGFloat = 20) -> some View {
        if service == .spotify {
            // Pre-render Spotify image at fixed size to prevent it from expanding
            if let originalImage = UIImage(named: "spotify") {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
                let resizedImage = renderer.image { context in
                    originalImage.draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
                }
                Image(uiImage: resizedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Image("spotify")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
        } else {
            Image(systemName: service.iconName)
                .font(.system(size: size))
                .frame(width: size, height: size)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Music Service")
                            .foregroundColor(.primary)
                        Spacer()
                        Menu {
                            ForEach(MusicService.allCases, id: \.rawValue) { service in
                                Button {
                                    selectedMusicService = service.rawValue
                                    UserDefaults.standard.set(service.rawValue, forKey: "widgetMusicService")
                                } label: {
                                    HStack(spacing: 8) {
                                        serviceIcon(for: service)
                                        Text(service.displayName)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                serviceIcon(for: currentMusicService)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                    }
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("Choose which music service to open when tapping albums in widgets")
                }
                
                Section {
                    // App Information
                    HStack {
                        Text("Version")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
                
                Section {
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            showingContactMail = true
                        }
                    } label: {
                        HStack {
                            Text("Contact Me")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Support")
                } footer: {
                    Text("Have a feature request or question? Send us an email!")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingContactMail) {
                if MFMailComposeViewController.canSendMail() {
                    MailView(
                        recipients: ["shortlistapp01@gmail.com"],
                        subject: contactEmailSubject,
                        messageBody: contactEmailBody,
                        isHTML: false
                    )
                } else {
                    // Fallback for when mail is not available
                    VStack(spacing: 20) {
                        Text("Email Not Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your device is not configured to send emails. Please configure Mail in Settings or contact us at shortlistapp01@gmail.com")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("OK") {
                            showingContactMail = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(40)
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

