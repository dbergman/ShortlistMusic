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

        init(album: Content, shortlist: Shortlist, viewModel: ViewModel) {
            let _ = print("dustin AlbumView init")
            
            self.viewModel = viewModel
            self.shortlist = shortlist
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
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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

                        Text(viewModel.album?.releaseYear)
                            .font(Theme.shared.avenir(size: 14, weight: .thin))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                            .padding([.leading], 20)

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
                                    .background(Color.black)
                                    .foregroundColor(.white)
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
                                    .background(Color.green)
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
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                            .padding([.leading, .trailing], 5)
                        if let tracks = viewModel.album?.trackDetails {
                            ForEach(Array(zip(tracks.indices, tracks)), id: \.1.id) { index, track in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(Theme.shared.avenir(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Circle().fill(Color.black))
                                        .overlay(
                                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
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
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding([.leading, .trailing], 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomBarButton(systemName: albumOnShortlist ? "minus.circle" : "plus.circle") {
                        Task {
                            if albumOnShortlist {
                                await viewModel.removeAlbumFromShortlist()
                            } else {
                                await viewModel.addAlbumToShortlist()
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
    
    private var navigationTitle: String {
        viewModel.album?.title ?? "Album"
    }

    init(albumType: AlbumType, shortlist: Shortlist) {
        self.albumType = albumType
        self.shortlist = shortlist
        self._viewModel = StateObject(wrappedValue: ViewModel(
            album: nil,
            shortlist: shortlist,
            screenSize: UIScreen.main.bounds.size.width
        ))
    }
    
    var body: some View {
        Group {
            if viewModel.isloading {
                loadingPlaceholder()
            } else if let album = viewModel.album {
                AlbumView(album: album, shortlist: shortlist, viewModel: viewModel)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBarButton.backButton {
            dismiss()
        })
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
