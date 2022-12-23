//
//  SearchMusicKit.swift
//  shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import MusicKit
import SwiftUI

struct SearchMusicKit: View {
    
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
        }
    }
    
    /// The top-level content view.
    private var rootView: some View {
        NavigationStack {
            navigationViewContents
                .navigationTitle("Music Albums")
        }
        .searchable(text: $searchTerm, prompt: "Albums")
    }
    
    // MARK: - Search results requesting
    
    /// The current search term the user enters.
    @State private var searchTerm = ""
    
    /// The albums the app loads using MusicKit that match the current search term.
    @State private var albums: MusicItemCollection<Album> = []

    /// A list of albums to display below the search bar.
    private var searchResultsList: some View {
        List(albums) { album in
            NavigationLink(value: album) {
                AlbumCell(album)
            }
        }
        .navigationTitle("Album")
        .navigationDestination(for: Album.self) { album in
            AlbumView(album: album)
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
                    var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self])
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
            self.albums = searchResponse.albums
        }
    }
    
    /// Safely resets the `albums` property on the main thread.
    @MainActor
    private func reset() {
        self.albums = []
    }
}

// MARK: - Previews

struct SearchMusicKit_Previews: PreviewProvider {
    static var previews: some View {
        SearchMusicKit()
    }
}

/// `AlbumCell` is a view to use in a SwiftUI `List` to represent an `Album`.
struct AlbumCell: View {
    
    // MARK: - Object lifecycle
    
    init(_ album: Album) {
        self.album = album
    }
    
    // MARK: - Properties
    
    let album: Album
    
    // MARK: - View
    
    var body: some View {
        MusicItemCell(
            artwork: album.artwork,
            title: album.title,
            subtitle: album.artistName
        )
    }
}

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
