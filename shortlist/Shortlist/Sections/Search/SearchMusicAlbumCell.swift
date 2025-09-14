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
            HStack(alignment: .top, spacing: 16) {
                AsyncImage(url: album.artworkURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 8) {
                    Text(album.name)
                        .font(Theme.shared.avenir(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if !album.artist.isEmpty {
                        Text(album.artist)
                            .font(Theme.shared.avenir(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    if !album.releaseYear.isEmpty {
                        Text(album.releaseYear)
                            .font(Theme.shared.avenir(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 8)
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

