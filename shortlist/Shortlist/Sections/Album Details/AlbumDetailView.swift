//
//  AlbumDetailView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/21/22.
//

import CloudKit
import MusicKit
import SkeletonUI
import SwiftUI

extension AlbumDetailView {
    struct Content {
        let id: String
        let artist: String
        let artworkURL: URL?
        let title: String
        let upc: String?
        let releaseYear: String?
        let appleAlbumURL: URL?
        let spotifyAlbumSearchDeeplink: URL?
        var recordID: CKRecord.ID?
        let trackDetails: [TrackDetails]

        struct TrackDetails: Hashable, Identifiable {
            let id = UUID()
            let title: String
            let duration: String
        }
    }
}

// MARK: - Constants
extension AlbumDetailView {
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let verticalSpacing: CGFloat = 24
        static let contentSpacing: CGFloat = 12
    }
}

// MARK: - Album Artwork View
extension AlbumDetailView {
    struct AlbumArtworkView: View {
        let artworkURL: URL?
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: Layout.horizontalPadding)
                
                AsyncImage(url: artworkURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .cornerRadius(12)
                            .shadow(
                                color: colorScheme == .dark ? 
                                    Color.black.opacity(0.5) : 
                                    Color.black.opacity(0.2),
                                radius: colorScheme == .dark ? 12 : 8,
                                x: 0,
                                y: colorScheme == .dark ? 6 : 4
                            )
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                
                Spacer()
                    .frame(width: Layout.horizontalPadding)
            }
        }
    }
}

// MARK: - Track List View
extension AlbumDetailView {
    struct TrackListView: View {
        let tracks: [Content.TrackDetails]
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            VStack(alignment: .leading, spacing: Layout.contentSpacing) {
                Text("Track List")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal, Layout.horizontalPadding)
                
                ForEach(Array(zip(tracks.indices, tracks)), id: \.1.id) { index, track in
                    HStack {
                        Text("\(index + 1)")
                            .font(Theme.shared.avenir(size: 14, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(colorScheme == .dark ? Color.white : Color.black))
                            .overlay(
                                Circle().stroke(
                                    colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.3),
                                    lineWidth: 1
                                )
                            )
                        Text(track.title)
                            .font(Theme.shared.avenir(size: 14, weight: .medium))
                        Spacer()
                        Text(track.duration)
                            .font(Theme.shared.avenir(size: 14, weight: .thin))
                    }
                    .padding(.horizontal, Layout.horizontalPadding)
                }
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
            )
            .cornerRadius(16)
            .shadow(
                color: colorScheme == .dark ? 
                    Color.black.opacity(0.3) : 
                    Color.black.opacity(0.1),
                radius: colorScheme == .dark ? 15 : 10,
                x: 0,
                y: colorScheme == .dark ? 8 : 5
            )
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Album View
extension AlbumDetailView {
    struct AlbumView: View {
        private var shortlist: Shortlist
        @State private var albumOnShortlist = false
        @ObservedObject private var viewModel: ViewModel
        @Environment(\.colorScheme) private var colorScheme
        @Binding var albumWasAdded: Bool
        @Binding var isPresented: Bool

        init(album: Content, shortlist: Shortlist, viewModel: ViewModel, albumWasAdded: Binding<Bool>, isPresented: Binding<Bool>) {
            self.viewModel = viewModel
            self.shortlist = shortlist
            self._albumWasAdded = albumWasAdded
            self._isPresented = isPresented
        }
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
                    albumHeaderSection
                    serviceButtons
                    if let tracks = viewModel.album?.trackDetails, !tracks.isEmpty {
                        TrackListView(tracks: tracks)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomBarButton(systemName: albumOnShortlist ? "trash" : "plus.circle") {
                        Task {
                            if albumOnShortlist {
                                await viewModel.removeAlbumFromShortlist()
                                albumWasAdded = false
                            } else {
                                await viewModel.addAlbumToShortlist()
                                albumWasAdded = true
                            }
                            albumOnShortlist.toggle()
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    albumOnShortlist = await viewModel.isAlbumOnShortlist()
                }
            }
        }
        
        // MARK: - Album Header Section
        private var albumHeaderSection: some View {
            VStack(alignment: .leading, spacing: Layout.contentSpacing) {
                AlbumArtworkView(artworkURL: viewModel.album?.artworkURL)
                
                if let releaseYear = viewModel.album?.releaseYear, !releaseYear.isEmpty {
                    Text(releaseYear)
                        .font(Theme.shared.avenir(size: 14, weight: .thin))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .padding(.horizontal, Layout.horizontalPadding)
                }

                Text(viewModel.album?.title ?? "")
                    .font(Theme.shared.avenir(size: 28, weight: .bold))
                    .padding(.horizontal, Layout.horizontalPadding)

                Text(viewModel.album?.artist ?? "")
                    .font(Theme.shared.avenir(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, Layout.horizontalPadding)
            }
        }
        
        // MARK: - Service Buttons
        private var serviceButtons: some View {
            VStack(spacing: 16) {
                appleMusicButton
                if viewModel.isSpotifyInstalled() {
                    spotifyButton
                }
            }
        }
        
        private var appleMusicButton: some View {
            Button(action: {
                guard let albumURL = viewModel.album?.appleAlbumURL,
                      let albumTitle = viewModel.album?.title,
                      let artist = viewModel.album?.artist else { return }

                AnalyticsManager.shared.logAlbumOpenedInService(
                    albumTitle: albumTitle,
                    artist: artist,
                    service: "apple_music"
                )

                UIApplication.shared.open(albumURL)
            }) {
                Label("Listen on Apple Music", systemImage: "applelogo")
                    .font(Theme.shared.avenir(size: 16, weight: .medium))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.white : Color.black)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, Layout.horizontalPadding)
        }
        
        private var spotifyButton: some View {
            Button(action: {
                guard let spotifyURL = viewModel.album?.spotifyAlbumSearchDeeplink,
                      let albumTitle = viewModel.album?.title,
                      let artist = viewModel.album?.artist else { return }

                AnalyticsManager.shared.logAlbumOpenedInService(
                    albumTitle: albumTitle,
                    artist: artist,
                    service: "spotify"
                )

                UIApplication.shared.open(spotifyURL)
            }) {
                Label {
                    Text("Listen on Spotify")
                } icon: {
                    Image("spotify")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .font(Theme.shared.avenir(size: 16, weight: .medium))
                .padding()
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color.green.opacity(0.8) : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, Layout.horizontalPadding)
        }
    }
}

// MARK: - Main Album Detail View
struct AlbumDetailView: View {
    enum AlbumType {
        case musicKit(Album)
        case shortlistAlbum(ShortlistAlbum)
    }

    private var shortlist: Shortlist
    private var albumType: AlbumType
    @StateObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var albumWasAdded = false
    @Binding var isPresented: Bool
    private var isInModalContext: Bool
    
    private var navigationTitle: String {
        viewModel.album?.title ?? "Album"
    }

    init(albumType: AlbumType, shortlist: Shortlist, isPresented: Binding<Bool>? = nil) {
        self.albumType = albumType
        self.shortlist = shortlist
        self._isPresented = isPresented ?? .constant(false)
        self.isInModalContext = isPresented != nil
        self._viewModel = StateObject(wrappedValue: ViewModel(
            album: nil,
            shortlist: shortlist
        ))
    }
    
    var body: some View {
        ZStack {
            Group {
                if viewModel.isloading {
                    loadingPlaceholder()
                } else if let album = viewModel.album {
                    AlbumView(
                        album: album,
                        shortlist: shortlist,
                        viewModel: viewModel,
                        albumWasAdded: $albumWasAdded,
                        isPresented: $isPresented
                    )
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            viewModel.screenSize = geometry.size.width
                        }
                        .onChange(of: geometry.size.width) { _, newWidth in
                            viewModel.screenSize = newWidth
                        }
                }
            )
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBarButton.backButton {
                        if albumWasAdded && isInModalContext {
                            isPresented = false
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .task {
                switch albumType {
                case .musicKit(let album):
                    await viewModel.loadTracks(for: album)
                case .shortlistAlbum(let shortlistAlbum):
                    await viewModel.getAlbum(
                        shortListAlbum: shortlistAlbum,
                        shortlist: shortlist
                    )
                }
            }
            .overlay(
                ToastOverlay(
                    showToast: $viewModel.showToast,
                    toastMessage: $viewModel.toastMessage,
                    toastType: $viewModel.toastType
                )
            )
            
            if viewModel.isAddingToShortlist || viewModel.isRemovingFromShortlist {
                loadingOverlay
            }
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .allowsHitTesting(true)
            
            VStack(spacing: 20) {
                SpinningRecordView(
                    size: 80,
                    color: viewModel.isAddingToShortlist ? .blue : .red
                )
                
                Text(viewModel.isAddingToShortlist ? "Adding to Shortlist..." : "Removing from Shortlist...")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Please wait...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            )
            .allowsHitTesting(false)
        }
    }
    
    // MARK: - Loading Placeholder
    @ViewBuilder
    private func loadingPlaceholder() -> some View {
        ScrollView {
            GeometryReader { geometry in
                let imageSize = max(100, geometry.size.width - (Layout.horizontalPadding * 2))
                VStack(alignment: .leading) {
                    Rectangle()
                        .skeleton(
                            with: true,
                            size: CGSize(width: imageSize, height: imageSize),
                            shape: .rectangle
                        )
                        .scaledToFit()
                        .cornerRadius(12)
                        .frame(width: imageSize, height: imageSize)
                        .padding(.bottom, 20)
                        .padding(.horizontal, Layout.horizontalPadding)
                    
                    Text("")
                        .skeleton(
                            with: true,
                            size: CGSize(width: 75, height: 25),
                            shape: .rectangle
                        )
                        .padding(.bottom, 20)
                        .padding(.horizontal, Layout.horizontalPadding)
                    
                    ForEach(0..<6, id: \.self) { _ in
                        Text("")
                            .skeleton(
                                with: true,
                                size: CGSize(width: imageSize, height: 40),
                                shape: .rectangle
                            )
                            .padding(.bottom, 20)
                            .padding(.horizontal, Layout.horizontalPadding)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Previews
struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlbumDetailView(
                albumType: .shortlistAlbum(TestData.ShortListAlbums.revolverShortListAlbum),
                shortlist: TestData.ShortLists.shortList
            )
        }
        .preferredColorScheme(.light)
        .previewDisplayName("Light Mode")
        
        NavigationView {
            AlbumDetailView(
                albumType: .shortlistAlbum(TestData.ShortListAlbums.revolverShortListAlbum),
                shortlist: TestData.ShortLists.shortList
            )
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
