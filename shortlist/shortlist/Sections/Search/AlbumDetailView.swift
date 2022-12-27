//
//  AlbumDetailView.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/21/22.
//

import MusicKit
import SwiftUI

extension AlbumDetailView {
    struct AlbumDetails {
        let artist: String
        let artworkURL: URL?
        let title: String
        let trackDetails: [TrackDetails]
        
        struct TrackDetails: Hashable, Identifiable {
            let id = UUID()
            let title: String
            let duration: String
        }
    }
}

extension AlbumDetailView {
    struct AlbumView: View {
        private var albumDetails: AlbumDetailView.AlbumDetails

        init(albumDetails: AlbumDetailView.AlbumDetails) {
            self.albumDetails = albumDetails
        }
        
        var body: some View {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    // Display the album cover image
                    AsyncImage(url: albumDetails.artworkURL)
                        .cornerRadius(8)
                    
                    // Display the album title and artist name
                    Text(albumDetails.title)
                        .font(.title)
                        .bold()
                    Text(albumDetails.artist)
                        .font(.subheadline)
                    
                    // Display a list of tracks for the album
                    if let theTracks = albumDetails.trackDetails {
                        ForEach(theTracks) { track in
                            HStack {
                                Text(track.title)
                                    .font(.headline)
                                Spacer()
                                Text(track.duration)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AlbumDetailView: View {
    private var album: Album
    
    @StateObject private var viewModel = ViewModel()
    
    init(album: Album) {
        self.album = album
    }
    
    var body: some View {
        ProgressView()
            .task {
                await self.viewModel.loadTracks(
                    for: album,
                    size: UIScreen.main.bounds.size.width
                )
            }
            .opacity(viewModel.albumDetails == nil ? 1 : 0)
        if let albumDetails = viewModel.albumDetails {
            AlbumView(albumDetails: albumDetails)
                .task {
                    await self.viewModel.loadTracks(
                        for: album,
                        size: UIScreen.main.bounds.size.width
                    )
                }
        }
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let albumDetails = AlbumDetailView.AlbumDetails(
            artist: "Panda Bear and Sonic Boom",
            artworkURL: URL(string: "https://is3-ssl.mzstatic.com/image/thumb/Music112/v4/07/89/c6/0789c6e0-5dad-404c-ac40-9603659dab77/887828051366.png/390x390bb.jpg"),
            title: "Reset",
            trackDetails: [
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Gettin' to the Point", duration: "2:30"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Go On", duration: "4:46"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Everyday", duration: "3:52"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Edge of the Edge", duration: "4:48"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "In My Body", duration: "3:51"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Whirlpool", duration: "5:01"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Danger", duration: "5:38"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Livin' in the After", duration: "2:54"),
                AlbumDetailView.AlbumDetails.TrackDetails(title: "Everything's Been Leading to This", duration:"5:08")
            ]
        )

        AlbumDetailView.AlbumView.init(albumDetails: albumDetails)
    }
}
