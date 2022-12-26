//
//  SearchAlbumsViewModel.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/24/22.
//

import Foundation
import MusicKit

extension SearchAlbumsView {
    class ViewModel: ObservableObject {
        @Published var albums: MusicItemCollection<Album> = []
        
        func loadAlbums(for artist: Artist) async {
            let artistWithDetails = try? await artist.with([.albums])
            
            DispatchQueue.main.async {
                self.albums = artistWithDetails?.albums ?? []
            }
        }
    }
}
