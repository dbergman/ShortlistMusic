//
//  SearchAlbumsView.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/24/22.
//

import MusicKit
import SwiftUI

struct SearchAlbumsView: View {
    private let artist: Artist
    @StateObject private var viewModel = ViewModel()

    init(artist: Artist) {
        self.artist = artist
    }
    
    var body: some View {
        List {
            ForEach(viewModel.albums) { album in
                NavigationLink(value: album) {
                    MusicItemCell(
                        artwork: album.artwork,
                        title: album.title,
                        subtitle: album.artistName
                    )
                }
            }
        }
        .task {
            await self.viewModel.loadAlbums(for: artist)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(artist.name)
        .navigationDestination(for: Album.self) { album in
            AlbumView(album: album)
        }
    }
}

//struct SearchAlbumsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchAlbumsView(artist: <#Artist#>)
//    }
//}
