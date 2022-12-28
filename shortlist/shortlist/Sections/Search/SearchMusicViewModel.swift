//
//  SearchMusicViewModel.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/26/22.
//

import MusicKit
import Foundation

extension SearchMusicView {
    @MainActor class ViewModel: ObservableObject {
        @Published var artists: [Content.Artist] = []
        @Published var albums: [Content.Album] = []

        func performSearch(for searchTerm: String) async {
            var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Album.self, MusicKit.Artist.self])
            searchRequest.limit = 25
            let searchResponse = try? await searchRequest.response()
            
            artists = retrieveArtists(from: searchResponse)
            albums = retrieveAlbums(from: searchResponse)
        }
        
        func resetResults() {
            artists = []
            albums = []
        }

        private func retrieveArtists(from searchResponse: MusicCatalogSearchResponse?) -> [Content.Artist] {
            guard let artistSearchList = searchResponse?.artists else { return [] }
            
            var artists = [Content.Artist]()
            for (index, artist) in artistSearchList.enumerated() {
                artists.append(
                    Content.Artist(
                        name: artist.name,
                        artistImageURL: artist.artwork?.url(width: 60, height: 60),
                        musicKitArtist: artist
                    )
                )
                
                if index == 4 { break }
            }
            
            return artists
        }
        
        private func retrieveAlbums(from searchResponse:  MusicCatalogSearchResponse?) -> [Content.Album] {
            guard let albumSearchList = searchResponse?.albums else { return [] }
            
            var albums = [Content.Album]()
            for album in albumSearchList {
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
