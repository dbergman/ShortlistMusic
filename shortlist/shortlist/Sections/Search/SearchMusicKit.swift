//
//  SearchMusicKit.swift
//  shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import MusicKit
import SwiftUI

enum Route: Hashable {
    case artist(Artist)
    case album(Album)
}

struct SearchMusicKit: View {
    @Binding var isPresented: Bool
    
    // MARK: - View
    
    var body: some View {
        rootView
            .onChange(of: searchTerm, perform: requestUpdatedSearchResults)
    }
    
    /// The various components of the main navigation view.
    private var navigationViewContents: some View {
        VStack {
            searchResultsList
                .animation(.default, value: albums)
                .animation(.default, value: artists)
        }
    }
    
    /// The top-level content view.
    private var rootView: some View {
        NavigationStack {
            navigationViewContents
                .navigationTitle("Music Albums")
        }
        .searchable(text: $searchTerm, prompt: "Search for Artist or Album")
    }
    
    // MARK: - Search results requesting
    
    /// The current search term the user enters.
    @State private var searchTerm = ""
    
    /// The albums the app loads using MusicKit that match the current search term.
    @State private var albums: MusicItemCollection<Album> = []
    @State private var artists: MusicItemCollection<Artist> = []

    /// A list of albums to display below the search bar.
    private var searchResultsList: some View {
        List {
            Section("Artists") {
                ForEach(artists) { artist in
                    NavigationLink(value: Route.artist(artist)) {
                        Text(artist.name)
                    }
                }
            }
            Section("Albums") {
                ForEach(albums) { album in
                    NavigationLink(value: Route.album(album)) {
                        MusicItemCell(
                            artwork: album.artwork,
                            title: album.title,
                            subtitle: album.artistName
                        )
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Album")
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .album(let album):
                AlbumView(album: album)
            case .artist(let artist):
                SearchAlbumsView(artist: artist)
            }
        }
        .toolbar {
            Button("Done") {
                isPresented = false
            }
        }
    }
    
    /// Makes a new search request to MusicKit when the current search term changes.
    private func requestUpdatedSearchResults(for searchTerm: String) {
        Task {
            if searchTerm.isEmpty {
                await self.reset()
            } else {
                do {
                    // Issue a catalog search request for albums matching the search term.
                    var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self, Artist.self])
                    searchRequest.limit = 25
                    let searchResponse = try await searchRequest.response()
                    
                    // Update the user interface with the search response.
                    await self.apply(searchResponse, for: searchTerm)
                } catch {
                    print("Search request failed with error: \(error).")
                    await self.reset()
                }
            }
        }
    }
    
    /// Safely updates the `albums` property on the main thread.
    @MainActor
    private func apply(_ searchResponse: MusicCatalogSearchResponse, for searchTerm: String) {
        if self.searchTerm == searchTerm {
            self.albums = searchResponse.albums //[..<5]
            self.artists = searchResponse.artists
        }
    }
    
    /// Safely resets the `albums` property on the main thread.
    @MainActor
    private func reset() {
        self.artists = []
        self.albums = []
    }
}

// MARK: - Previews

//struct SearchMusicKit_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchMusicKit(isPresented: )
//    }
//}

/// `MusicItemCell` is a view to use in a SwiftUI `List` to represent a `MusicItem`.
struct MusicItemCell: View {
    
    // MARK: - Properties
    
    let artwork: Artwork?
    let title: String
    let subtitle: String
    
    // MARK: - View
    
    var body: some View {
        HStack {
            if let existingArtwork = artwork {
                VStack {
                    Spacer()
                    ArtworkImage(existingArtwork, width: 56)
                        .cornerRadius(6)
                    Spacer()
                }
            }
            VStack(alignment: .leading) {
                Text(title)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .padding(.top, -4.0)
                }
            }
        }
    }
}


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
