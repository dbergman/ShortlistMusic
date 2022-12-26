//
//  AlbumDetailView.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/21/22.
//

import MusicKit
import SwiftUI

struct AlbumDetails {
    let artist: String
    let artwork: Artwork
    let title: String
    let trackDetails: [TrackDetails]
    
    struct TrackDetails {
        let artist: String
        let title: String
        let duration: String
    }
}

struct AlbumView: View {
    var album: Album
    
    @State var tracks: MusicItemCollection<Track>?

    init(album: Album) {
        self.album = album
    }
    
    var formatter2: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }
    
    @MainActor
    func getTheTracks() async throws {
        let detailedAlbum = try await album.with([.artists, .tracks])
        tracks = detailedAlbum.tracks
       // let _ = print("dustin12 \(detailedAlbum.tracks)")
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                // Display the album cover image
                if let artwork = album.artwork {
                    ArtworkImage(artwork, width: UIScreen.main.bounds.size.width)
                        .cornerRadius(8)
                    
                }
                
                // Display the album title and artist name
                Text(album.title)
                    .font(.title)
                    .bold()
                Text(album.artistName)
                    .font(.subheadline)
                
                
                // Display a list of tracks for the album
                if let theTracks = tracks {
                    ForEach(theTracks) { track in
                        HStack {
                            Text(track.title)
                                .font(.headline)
                            Spacer()
                            Text("\(formatter2.string(from: track.duration!)!)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .task {
                try? await getTheTracks()
            }
        }
    }
}

//struct AlbumDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumView(album: <#Album#>)
//    }
//}
