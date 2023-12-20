//
//  SearchMusicViewModel.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/26/22.
//

import MusicKit
import Foundation

extension SearchMusicView {
    @MainActor class ViewModel: ObservableObject {
        @Published var albums: [Content.Album] = []

        func performSearch(for searchTerm: String) async {
            var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Album.self])
            searchRequest.limit = 25
            let searchResponse = try? await searchRequest.response()

            albums = retrieveAlbums(from: searchResponse)
        }
        
        func resetResults() {
            albums = []
        }

        private func retrieveAlbums(from searchResponse:  MusicCatalogSearchResponse?) -> [Content.Album] {
            guard let albumSearchList = searchResponse?.albums else { return [] }
            
            var albums = [Content.Album]()
            for album in albumSearchList {
                
                if album.artistName == "The Beatles" {
                    print("dustin: title \(album.title)")
                    print("dustin: artist \(album.artistName)")
                    print("dustin: artworkURL \(album.artwork?.url(width: 60, height: 60))")
                    print("dustin: upc \(album.upc)")
                    print("dustin:====================")
                }
                albums.append(
                    Content.Album(
                        name: album.title,
                        artworkURL: album.artwork?.url(width: 60, height: 60),
                        artist: album.artistName,
                        releaseYear: album.releaseYear,
                        musicKitAlbum: album
                    )
                )
            }
            
            return albums
        }
    }
}
