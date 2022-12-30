//
//  SearchMusicAlbumCell.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/28/22.
//

import SwiftUI

extension SearchMusicView {
    struct SearchMusicAlbumCell: View {
        let album: Content.Album
        
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
                    Text(album.name)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    if !album.artist.isEmpty {
                        Text(album.artist)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .padding(.top, -4.0)
                    }
                    if !album.releaseYear.isEmpty {
                        Text(album.releaseYear)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                            .font(.body)
                            .padding(.top, -2.0)
                    }
                }
            }
        }
    }
}

struct Previews_SearchMusicAlbumCell_Previews: PreviewProvider {
    static var previews: some View {
        let album = SearchMusicView.Content.Album(
            name: "A Light for Attracting Attention",
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/26/64/dd/2664dd24-5f50-c8d7-3122-5956e94cf3dc/191404119655.png/60x600bb.jpg"),
            artist: "The Smile",
            releaseYear: "2022",
            musicKitAlbum: nil)
        SearchMusicView.SearchMusicAlbumCell(album: album)
    }
}

