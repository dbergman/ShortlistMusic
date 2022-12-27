//
//  SearchAlbumsViewModel.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/24/22.
//

import Foundation
import MusicKit

extension SearchAlbumsView {
    @MainActor  class ViewModel: ObservableObject {
        @Published var artistAlbums: [Content]?
        
        func loadAlbums(for artist: Artist, size: CGFloat) async {
            let artistWithDetails = try? await artist.with([.albums])
            
            guard let discography = artistWithDetails?.albums else { return }
            
            var albums = [Content]()
            
            for album in discography {
                let releaseYear: String

                if let releaseDate = album.releaseDate {
                    let myCalendar = Calendar(identifier: .gregorian)
                    releaseYear = "\(myCalendar.component(.year, from: releaseDate))"
                } else {
                    releaseYear = ""
                }

                let record = Content(
                    album: album,
                    artworkURL: album.artwork?.url(width: Int(size), height: Int(size)),
                    title: album.title,
                    releaseYear: releaseYear
                )
                
                albums.append(record)
            }
            
            artistAlbums = albums.sorted { $0.releaseYear > $1.releaseYear }
        }
    }
}
