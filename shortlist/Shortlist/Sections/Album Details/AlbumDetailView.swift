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
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        AsyncImage(url: viewModel.album?.artworkURL) { phase in
                            let side = UIScreen.main.bounds.width - 40

                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: side, height: side)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: side, height: side)
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
                                    .frame(width: side, height: side)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding([.leading, .trailing], 20)

                        if let releaseYear = viewModel.album?.releaseYear, !releaseYear.isEmpty {
                            Text(releaseYear)
                                .font(Theme.shared.avenir(size: 14, weight: .thin))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color.gray.opacity(0.2))
                                .cornerRadius(20)
                                .padding([.leading], 20)
                        }

                        Text(viewModel.album?.title)
                            .font(Theme.shared.avenir(size: 28, weight: .bold))
                            .padding([.leading, .trailing], 20)

                        Text(viewModel.album?.artist)
                            .font(Theme.shared.avenir(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding([.leading, .trailing], 20)

                        VStack(spacing: 16) {
                            Button(action: {
                                guard let albumURL = viewModel.album?.appleAlbumURL else { return }

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
                            .padding(.horizontal, 20)
                            
                            if viewModel.isSpotifyInstalled() {
                                Button(action: {
                                    guard
                                        let spotifyAlbumSearchDeeplinkURL = viewModel.album?.spotifyAlbumSearchDeeplink
                                    else {
                                        return
                                    }

                                    UIApplication.shared.open(spotifyAlbumSearchDeeplinkURL)
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
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Track List")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color.gray.opacity(0.2))
                            .cornerRadius(20)
                            .padding([.leading, .trailing], 5)
                        if let tracks = viewModel.album?.trackDetails {
                            ForEach(Array(zip(tracks.indices, tracks)), id: \.1.id) { index, track in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(Theme.shared.avenir(size: 14, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                        .frame(width: 28, height: 28)
                                        .background(Circle().fill(colorScheme == .dark ? Color.white : Color.black))
                                        .overlay(
                                            Circle().stroke(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                    Text(track.title)
                                        .font(Theme.shared.avenir(size: 14, weight: .medium))
                                    Spacer()
                                    Text(track.duration)
                                        .font(Theme.shared.avenir(size: 14, weight: .thin))
                                }
                                .padding([.leading, .trailing], 5)
                            }
                        }
                    }
                    .padding()
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
                    .padding([.leading, .trailing], 20)
                }
                .padding()
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
    }
}

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
            shortlist: shortlist,
            screenSize: UIScreen.main.bounds.size.width
        ))
    }
    
    var body: some View {
        ZStack {
            Group {
                if viewModel.isloading {
                    loadingPlaceholder()
                } else if let album = viewModel.album {
                    AlbumView(album: album, shortlist: shortlist, viewModel: viewModel, albumWasAdded: $albumWasAdded, isPresented: $isPresented)
                }
            }
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
                // Toast overlay
                ToastOverlay(
                    showToast: $viewModel.showToast,
                    toastMessage: $viewModel.toastMessage,
                    toastType: $viewModel.toastType
                )
            )
            
            // Full-screen loading overlay
            if viewModel.isAddingToShortlist || viewModel.isRemovingFromShortlist {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                
                VStack(spacing: 20) {
                    SpinningRecordView(size: 80, color: viewModel.isAddingToShortlist ? .blue : .red)
                    
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
    }
    
    @ViewBuilder
    private func loadingPlaceholder() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                let placeHolderSize = UIScreen.main.bounds.size.width - 40
                Rectangle()
                    .skeleton(
                        with: true,
                        size: CGSize(width: placeHolderSize, height: placeHolderSize),
                        shape: .rectangle
                    )
                    .scaledToFit()
                    .cornerRadius(12)
                    .frame(width: placeHolderSize, height: placeHolderSize)
                    .padding(.bottom, 20)
                
                Text("")
                    .skeleton(
                        with: true,
                        size: CGSize(width: 75, height: 25),
                        shape: .rectangle
                    )
                    .padding(.bottom, 20)
                
                Text("")
                    .skeleton(
                        with: true,
                        size: CGSize(width: placeHolderSize, height: 40),
                        shape: .rectangle
                    )
                    .padding(.bottom, 20)
                
                Text("")
                    .skeleton(
                        with: true,
                        size: CGSize(width: placeHolderSize, height: 40),
                        shape: .rectangle
                    )
                    .padding(.bottom, 20)
                
                Text("")
                    .skeleton(
                        with: true,
                        size: CGSize(width: placeHolderSize, height: 40),
                        shape: .rectangle
                    )
                    .padding(.bottom, 20)
                
                Text("")
                    .skeleton(
                        with: true,
                        size: CGSize(width: placeHolderSize, height: 40),
                        shape: .rectangle
                    )
                    .padding(.bottom, 20)
                
                Text("")
                    .skeleton(
                        with: true,
                        size: CGSize(width: placeHolderSize, height: 40),
                        shape: .rectangle
                    )
                    .padding(.bottom, 20)
                
                Text("")
                    .skeleton(
                        with: true,
                        size: CGSize(width: placeHolderSize, height: 40),
                        shape: .rectangle
                    )
                    .padding(.bottom, 20)
                
                Spacer()
            }
        }
    }
}

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
