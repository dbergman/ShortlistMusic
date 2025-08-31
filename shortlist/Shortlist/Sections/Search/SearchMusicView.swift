//
//  SearchMusicView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import MusicKit
import SwiftUI

extension SearchMusicView {
    struct Content {
        struct Artist: Hashable, Identifiable {
            let id = UUID()
            let name: String
            let artistImageURL: URL?
            let musicKitArtist: MusicKit.Artist?
        }
        
        struct Album: Hashable, Identifiable {
            let id = UUID()
            let name: String
            let artworkURL: URL?
            let artist: String
            let releaseYear: String
            let musicKitAlbum: MusicKit.Album?
        }
    }
}

extension SearchMusicView {
    enum Route: Hashable {
        case artist(Content.Artist)
        case album(Content.Album)
    }
}

struct SearchMusicView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = ViewModel()
    @State private var searchTerm = ""
    let shortlist: Shortlist
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchResultsList(albums: viewModel.albums)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Add to ShortList")
                                .font(Theme.shared.avenir(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                        }
                    }
                    .navigationDestination(for: SearchMusicView.Route.self) { route in
                        switch route {
                        case .album(let album):
                            if let albumMK = album.musicKitAlbum {
                                let albumType = AlbumDetailView.AlbumType.musicKit(albumMK)
                                AlbumDetailView(albumType:  albumType, shortlist: shortlist)
                            }
                            
                        case .artist(let artist):
                            if let artistMK = artist.musicKitArtist {
                                SearchAlbumsView(artist: artistMK, shortlist: shortlist)
                            }
                        }
                    }
                    .toolbar {
                        Button("Done") {
                            isPresented = false
                        }
                        .font(Theme.shared.avenir(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    }
            }
        }
        .searchable(text: $searchTerm, prompt: "Search by Artist")
        .onChange(of: searchTerm) { _, newValue in
            requestUpdatedSearchResults(for: newValue)
        }
        .tint(.primary)
    }
    
    private func requestUpdatedSearchResults(for searchTerm: String) {
        Task {
            if searchTerm.isEmpty {
                self.viewModel.resetResults()
            } else {
                await viewModel.performSearch(for: searchTerm)
            }
        }
    }
}

extension SearchMusicView {
    struct SearchResultsList: View {
        private let albums: [Content.Album]

        init(albums: [Content.Album]) {
            self.albums = albums
        }

        var body: some View {
            if albums.isEmpty {
                emptyStateView()
            } else {
                List {
                    Section {
                        ForEach(albums) { album in
                            ZStack {
                                NavigationLink(value: SearchMusicView.Route.album(album)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                HStack {
                                    SearchMusicView.SearchMusicAlbumCell(album: album)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .imageScale(.small)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        
        @ViewBuilder
        private func emptyStateView() -> some View {
            VStack(spacing: 24) {
                Spacer()
                
                // Main message
                VStack(spacing: 12) {
                    Text("Search for Music")
                        .font(Theme.shared.avenir(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Start typing an artist name above to discover albums and add them to your shortlist")
                        .font(Theme.shared.avenir(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 32)
                }
                
                // Search tips
                VStack(spacing: 16) {
                    Text("Search Tips:")
                        .font(Theme.shared.avenir(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Try artist names like 'The Beatles' or 'The Clash'")
                                .font(Theme.shared.avenir(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "music.note")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text("Browse albums and tap to add them to your shortlist")
                                .font(Theme.shared.avenir(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            Text("Discover new music and build your perfect collection")
                                .font(Theme.shared.avenir(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding()
        }
    }
}




struct Previews_SearchMusicView_Previews: PreviewProvider {
    static var previews: some View {
        let albums = [
            SearchMusicView.Content.Album(
                name: "About Time (2005 Remaster)",
                artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/7d/6d/18/7d6d18a5-2368-cd42-3eb3-58493c2bba01/0045778673865.png/60x60bb.jpg"),
                artist: "Pennywise",
                releaseYear: "1995",
                musicKitAlbum: nil
            ),
            SearchMusicView.Content.Album(
                name: "Full Circle (2005 Remaster)",
                artworkURL: URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music112/v4/ad/7c/9f/ad7c9f8c-1d43-2512-da06-0dcebbef60b0/0045778673902.png/60x60bb.jpg"),
                artist: "Pennywise",
                releaseYear: "1997",
                musicKitAlbum: nil
            ),
            SearchMusicView.Content.Album(
                name: "Unknown Road (2005 Remaster)",
                artworkURL: URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music112/v4/56/f3/d1/56f3d11f-682e-9bb7-6543-f5318563c2fa/0045778673766.png/60x60bb.jpg"),
                artist: "Pennywise",
                releaseYear: "1993",
                musicKitAlbum: nil
            )
        ]
        
        SearchMusicView.SearchResultsList(albums: albums)
    }
}
