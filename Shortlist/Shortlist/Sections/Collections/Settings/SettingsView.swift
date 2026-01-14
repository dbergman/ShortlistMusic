//
//  SettingsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/13/26.
//

import SwiftUI

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
    
    private var currentMusicService: MusicService {
        MusicService(rawValue: selectedMusicService) ?? .spotify
    }
    
    @ViewBuilder
    private func serviceIcon(for service: MusicService, size: CGFloat = 16) -> some View {
        if service == .spotify {
            Image(service.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
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
                    // Music Service Selection for Widgets
                    HStack {
                        Text("Widget Music Service")
                            .foregroundColor(.primary)
                        Spacer()
                        Menu {
                            ForEach(MusicService.allCases, id: \.rawValue) { service in
                                Button {
                                    selectedMusicService = service.rawValue
                                } label: {
                                    HStack(spacing: 6) {
                                        serviceIcon(for: service)
                                        Text(service.displayName)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                serviceIcon(for: currentMusicService)
                                Text(currentMusicService.displayName)
                                    .foregroundColor(.primary)
                            }
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
                        Text("4.1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("2")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

