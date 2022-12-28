//
//  SearchMusicView.swift
//  shortlist
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
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchResultsList(artists: viewModel.artists, albums: viewModel.albums)
                    .scrollDismissesKeyboard(.immediately)
                    .navigationTitle("Add to {Name}")
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .album(let album):
                            if let albumMK = album.musicKitAlbum {
                                AlbumDetailView(album:  albumMK)
                            }
                            
                        case .artist(let artist):
                            if let artistMK = artist.musicKitArtist {
                                SearchAlbumsView(artist: artistMK)
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
                        NavigationLink(value: Route.artist(artist)) {
                            SearchMusicArtistCell(artist: artist)
                        }
                    }
                }
                Section("Albums") {
                    ForEach(albums) { album in
                        NavigationLink(value: Route.album(album)) {
                            SearchMusicAlbumCell(album: album)
                        }
                    }
                }
            }
        }
    }
}





// MARK: - Previews

//struct SearchMusicKit_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchMusicKit(isPresented: )
//    }
//}


//struct SearchMusicKit: View {
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        ZStack {
//            Button("Dismiss Modal") {
//                presentationMode.wrappedValue.dismiss()
//            }
//        }
//    }
//}
//
//struct SearchMusicKit_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchMusicKit()
//    }
//}
