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
                SearchResultsList(artists: viewModel.artists, albums: viewModel.albums)
                    .scrollDismissesKeyboard(.immediately)
                    .navigationTitle("Add to {Name}")
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
                    }
            }
        }
        .searchable(text: $searchTerm, prompt: "Search for Artist or Album")
        .onChange(of: searchTerm, perform: requestUpdatedSearchResults)
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
        private let artists: [Content.Artist]
        private let albums: [Content.Album]

        init(artists: [Content.Artist], albums: [Content.Album]) {
            self.artists = artists
            self.albums = albums
        }

        var body: some View {
            List {
                Section("Artists") {
                    ForEach(artists) { artist in
                        NavigationLink(value: SearchMusicView.Route.artist(artist)) {
                            SearchMusicView.SearchMusicArtistCell(artist: artist)
                        }
                    }
                }
                Section("Albums") {
                    ForEach(albums) { album in
                        NavigationLink(value: SearchMusicView.Route.album(album)) {
                            SearchMusicView.SearchMusicAlbumCell(album: album)
                        }
                    }
                }
            }
        }
    }
}


struct Previews_SearchMusicView_Previews: PreviewProvider {
    static var previews: some View {
        let artists = [
            SearchMusicView.Content.Artist(
                name: "Pennywise",
                artistImageURL: URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Features125/v4/b7/37/09/b73709de-5e70-3ae3-f675-d1d700029d32/mzm.zxgudqvp.jpg/60x60bb.jpg"),
                musicKitArtist: nil
            ),
            SearchMusicView.Content.Artist(
                name: "Pennywise",
                artistImageURL: URL(string:""),
                musicKitArtist: nil
            ),
            SearchMusicView.Content.Artist(
                name: "Pennywise",
                artistImageURL: URL(string:"https://is1-ssl.mzstatic.com/image/thumb/Music6/v4/a9/7a/03/a97a030b-4d23-2ead-ed46-8eb2a153dfe2/cover_10074670.jpg/60x60ac.jpg"),
                musicKitArtist: nil
            )
        ]
        
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
        
        SearchMusicView.SearchResultsList(artists: artists, albums: albums)
    }
}
