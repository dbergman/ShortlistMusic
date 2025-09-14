//
//  SearchMusicArtistCell.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/28/22.
//

import SwiftUI

extension SearchMusicView {
    struct SearchMusicArtistCell: View {
        let artist: Content.Artist
        
        var body: some View {
            HStack {
                VStack {
                    Spacer()
                    AsyncImage(url: artist.artistImageURL)
                        .cornerRadius(6)
                        .frame(width: 60, height: 60)
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text(artist.name)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct Previews_SearchMusicArtistCell_Previews: PreviewProvider {
    static var previews: some View {
        let artist = SearchMusicView.Content.Artist(
            name: "Bad Religion",
            artistImageURL: URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Features125/v4/a0/1e/75/a01e756e-d118-7629-10e6-ba299fb5a4f8/pr_source.png/60x60bb.jpg"),
            musicKitArtist: nil
        )
        
        SearchMusicView.SearchMusicArtistCell(artist: artist)
    }
}
