//
//  SearchAlbumsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/24/22.
//

import MusicKit
import SwiftUI

extension SearchAlbumsView {
    struct Content: Hashable, Identifiable {
        let id = UUID()
        let album: MusicKit.Album?
        let artworkURL: URL?
        let title: String
        let releaseYear: String
    }
}

extension SearchAlbumsView {
    struct SearchAlbumCell: View {
        let album: Content
        
        var body: some View {
            HStack {
                VStack {
                    Spacer()
                    AsyncImage(url: album.artworkURL)
                        .cornerRadius(6)
                        .frame(width: 60, height: 60)
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text(album.title)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    if !album.releaseYear.isEmpty {
                        Text(album.releaseYear)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .padding(.top, -4.0)
                    }
                }
            }
        }
    }
}

extension SearchAlbumsView {
    struct AlbumsView: View {
        private let albums: [Content]

        init(albums: [Content]) {
            self.albums = albums
        }
        
        var body: some View {
            List {
                ForEach(albums) { album in
                    NavigationLink(value: album.album) {
                        SearchAlbumsView.SearchAlbumCell(album: album)
                    }
                }
            }
        }
    }
}

struct SearchAlbumsView: View {
    private let artist: Artist
    @StateObject private var viewModel = ViewModel()
    
    init(artist: Artist) {
        self.artist = artist
    }
    
    var body: some View {
        AlbumsView(albums: viewModel.artistAlbums ?? [])
        .task {
            await self.viewModel.loadAlbums(for: artist, size: 60)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(artist.name)
        .navigationDestination(for: Album.self) { album in
            AlbumDetailView(album: album)
        }
    }
}

struct SearchAlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        let discography = [
            SearchAlbumsView.Content(
                album: nil,
                artworkURL: URL(string:"https://is1-ssl.mzstatic.com/image/thumb/Music123/v4/8c/68/18/8c6818e7-df33-f282-f7fd-b4f586ab1da1/194606000967.png/60x60bb.jpg"),
                title: "Person Pitch",
                releaseYear: "2007"
            ),
            SearchAlbumsView.Content(
                album: nil,
                artworkURL: URL(string:"https://is1-ssl.mzstatic.com/image/thumb/Music123/v4/3e/17/74/3e1774cf-c779-3a7c-0a40-571ce12fe2c2/194606001360.png/60x60bb.jpg"),
                title: "Tomboy",
                releaseYear: "2011"
            ),
            SearchAlbumsView.Content(
                album: nil,
                artworkURL: URL(string:"https://is5-ssl.mzstatic.com/image/thumb/Music5/v4/af/9b/cc/af9bcce1-eb8e-f901-ffc8-721f747cd028/dj.wqplrrlq.jpg/60x60bb.jpg"),
                title: "Panda Bear Meets the Grim Reaper",
                releaseYear: "2015"
            ),
            SearchAlbumsView.Content(
                album: nil,
                artworkURL: URL(string:"https://is2-ssl.mzstatic.com/image/thumb/Music128/v4/eb/3b/6e/eb3b6e03-2e32-1473-25fe-c2756c1083f5/dj.ptjosefa.jpg/60x60bb.jpg"),
                title: "Buoys",
                releaseYear: "2019"
            ),
            SearchAlbumsView.Content(
                album: nil,
                artworkURL: URL(string:"https://is3-ssl.mzstatic.com/image/thumb/Music112/v4/07/89/c6/0789c6e0-5dad-404c-ac40-9603659dab77/887828051366.png/60x60bb.jpg"),
                title: "Reset",
                releaseYear: "2022"
            )
        ]

        SearchAlbumsView.AlbumsView(albums: discography)
    }
}
