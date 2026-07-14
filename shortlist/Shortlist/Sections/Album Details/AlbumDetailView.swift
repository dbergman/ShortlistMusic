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
import UIKit

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
        let artworkNamespace: Namespace.ID?
        let artworkID: String?
        @Environment(\.colorScheme) private var colorScheme
        
        private enum ArtworkLayout {
            static let cornerRadius: CGFloat = 12
            /// Stable download size so AsyncImage isn’t recreated as layout settles.
            static let artworkPixelSize = 600
        }
        
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: Layout.horizontalPadding)
                
                GeometryReader { geometry in
                    let imageSize = max(100, geometry.size.width)
                    artworkContent(size: imageSize)
                        .frame(width: imageSize, height: imageSize)
                }
                .aspectRatio(1, contentMode: .fit)
                
                Spacer()
                    .frame(width: Layout.horizontalPadding)
            }
        }
        
        @ViewBuilder
        private func artworkContent(size: CGFloat) -> some View {
            if let url = ArtworkURLHelper.url(from: artworkURL, size: ArtworkLayout.artworkPixelSize) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ArtworkSkeletonPlaceholder(size: size, cornerRadius: ArtworkLayout.cornerRadius)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipped()
                            .cornerRadius(ArtworkLayout.cornerRadius)
                            .shadow(
                                color: colorScheme == .dark ?
                                    Color.black.opacity(0.5) :
                                    Color.black.opacity(0.2),
                                radius: colorScheme == .dark ? 12 : 8,
                                x: 0,
                                y: colorScheme == .dark ? 6 : 4
                            )
                            .transition(.opacity)
                    case .failure:
                        ArtworkSkeletonPlaceholder(size: size, cornerRadius: ArtworkLayout.cornerRadius)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                ArtworkSkeletonPlaceholder(size: size, cornerRadius: ArtworkLayout.cornerRadius)
            }
        }
    }
}

// MARK: - Navigation Transition Modifier
struct NavigationTransitionModifier: ViewModifier {
    let artworkNamespace: Namespace.ID?
    let artworkID: String?
    
    func body(content: Content) -> some View {
        if let namespace = artworkNamespace,
           let id = artworkID {
            content
                .navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            content
        }
    }
}


// MARK: - View Extension Helper
extension View {
    @ViewBuilder
    func applyIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
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
        private let album: Content
        private var shortlist: Shortlist
        @State private var blockInteractiveDismiss = true
        @ObservedObject private var viewModel: ViewModel
        @Environment(\.colorScheme) private var colorScheme
        @Binding var albumWasAdded: Bool
        @Binding var didModifyShortlist: Bool
        @Binding var isPresented: Bool

        init(album: Content, shortlist: Shortlist, viewModel: ViewModel, albumWasAdded: Binding<Bool>, didModifyShortlist: Binding<Bool>, isPresented: Binding<Bool>) {
            self.album = album
            self.viewModel = viewModel
            self.shortlist = shortlist
            self._albumWasAdded = albumWasAdded
            self._didModifyShortlist = didModifyShortlist
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
                    CustomBarButton(
                        systemName: viewModel.isAlbumOnShortlist ? "trash" : "plus.circle"
                    ) {
                        guard !viewModel.isAddingToShortlist,
                              !viewModel.isRemovingFromShortlist else { return }
                        
                        Task {
                            if viewModel.isAlbumOnShortlist {
                                await viewModel.removeAlbumFromShortlist()
                                if !viewModel.isAlbumOnShortlist {
                                    albumWasAdded = false
                                    didModifyShortlist = true
                                }
                            } else {
                                let didAdd = await viewModel.addAlbumToShortlist()
                                if didAdd {
                                    albumWasAdded = true
                                    didModifyShortlist = true
                                }
                            }
                        }
                    }
                    .disabled(viewModel.isAddingToShortlist || viewModel.isRemovingFromShortlist)
                }
            }
            .task {
                await viewModel.loadAlbumOnShortlistState()
            }
            .onAppear {
                // Block interactive dismiss gesture for 1 second to prevent image disappearing bug
                blockInteractiveDismiss = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    blockInteractiveDismiss = false
                }
            }
        }
        
        // MARK: - Album Header Section
        private var albumHeaderSection: some View {
            VStack(alignment: .leading, spacing: Layout.contentSpacing) {
                AlbumArtworkView(
                    artworkURL: viewModel.album?.artworkURL,
                    artworkNamespace: viewModel.artworkNamespace,
                    artworkID: viewModel.artworkID
                )
                .overlay {
                    if blockInteractiveDismiss {
                        Color.clear
                            .contentShape(Rectangle())
                            .highPriorityGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in }
                            )
                    }
                }
                
                if let releaseYear = viewModel.album?.releaseYear, !releaseYear.isEmpty {
                    Text(releaseYear)
                        .font(Theme.shared.avenir(size: 14, weight: .thin))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .padding(.horizontal, Layout.horizontalPadding)
                }

                Text(album.title)
                    .font(Theme.shared.avenir(size: 28, weight: .bold))
                    .padding(.horizontal, Layout.horizontalPadding)

                Text(album.artist)
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
    @State private var didModifyShortlist = false
    @Binding var isPresented: Bool
    private var isInModalContext: Bool
    private let onShortlistDidChange: (() -> Void)?
    private let onCloseSearch: (() -> Void)?
    private let onNavigateBack: (() -> Void)?
    
    private var navigationTitle: String {
        viewModel.album?.title ?? "Album"
    }

    init(
        albumType: AlbumType,
        shortlist: Shortlist,
        isPresented: Binding<Bool>? = nil,
        artworkNamespace: Namespace.ID? = nil,
        artworkID: String? = nil,
        onShortlistDidChange: (() -> Void)? = nil,
        onCloseSearch: (() -> Void)? = nil,
        onNavigateBack: (() -> Void)? = nil
    ) {
        self.albumType = albumType
        self.shortlist = shortlist
        self._isPresented = isPresented ?? .constant(false)
        self.isInModalContext = isPresented != nil
        self.onShortlistDidChange = onShortlistDidChange
        self.onCloseSearch = onCloseSearch
        self.onNavigateBack = onNavigateBack
        self._viewModel = StateObject(wrappedValue: ViewModel(
            album: nil,
            shortlist: shortlist,
            artworkNamespace: artworkNamespace,
            artworkID: artworkID
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
                        didModifyShortlist: $didModifyShortlist,
                        isPresented: $isPresented
                    )
                    // Keep identity stable when tracks refresh so the add control
                    // isn't remounted mid-tap.
                    .id(album.id)
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
            .modifier(NavigationTransitionModifier(
                artworkNamespace: viewModel.artworkNamespace,
                artworkID: viewModel.artworkID
            ))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBarButton.backButton {
                        navigateBack()
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
            .onDisappear {
                guard didModifyShortlist, !isInModalContext else { return }
                onShortlistDidChange?()
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
    
    private func navigateBack() {
        if isInModalContext && (albumWasAdded || didModifyShortlist) {
            onCloseSearch?()
            if onCloseSearch == nil {
                isPresented = false
            }
            return
        }
        
        // Prefer clearing the parent's navigationDestination item — more reliable
        // than dismiss() with zoom transitions.
        if let onNavigateBack {
            onNavigateBack()
        } else {
            dismiss()
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
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
                    ArtworkSkeletonPlaceholder(size: imageSize, cornerRadius: 12)
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
