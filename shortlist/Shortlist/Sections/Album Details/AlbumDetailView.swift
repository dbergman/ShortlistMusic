//
//  AlbumDetailView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/21/22.
//

import CloudKit
import MusicKit
import SwiftUI

extension AlbumDetailView {
    struct Content {
        let id: String
        let artist: String
        let artworkURL: URL?
        let title: String
        let upc: String?
        var recordID: CKRecord.ID?
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
        private var album: Content
        private var shortlist: Shortlist
        @State private var albumOnShortlist = false
        @StateObject private var viewModel = ViewModel(screenSize: UIScreen.main.bounds.size.width)

        init(album: Content, shortlist: Shortlist) {
            let _ = print("dustin AlbumView init")
            
            self.album = album
            self.shortlist = shortlist
        }
        
        var body: some View {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    AsyncImage(url: album.artworkURL)
                        .cornerRadius(8)

                    Text(album.title)
                        .font(.title)
                        .bold()
                    Text(album.artist)
                        .font(.subheadline)

                    ForEach(album.trackDetails) { track in
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    Task {
                        if albumOnShortlist {
                            viewModel.removeAlbumFromShortlist(album: album)
                        } else {
                            await viewModel.addAlbumToShortlist(shortlist: shortlist, album: album)
                        }
                        
                        albumOnShortlist.toggle()
                    }
                }) {
                    Image(systemName: albumOnShortlist ? "minus.circle" : "plus.circle")
                }
            }
            .onAppear {
                albumOnShortlist = isAlbumOnShortlist()
            }
        }
        
        private func isAlbumOnShortlist() -> Bool {
            return shortlist.albums?.contains { $0.id == album.id } == true
        }
    }
}

struct AlbumDetailView: View {
    enum AlbumType {
    case musicKit(Album)
    case shortlistAlbum(ShortListAlbum)
    }

    //private var album: Album
    private var shortlist: Shortlist
    private var albumType: AlbumType
    
    @StateObject private var viewModel = ViewModel(screenSize: UIScreen.main.bounds.size.width)
    
    init(albumType: AlbumType, shortlist: Shortlist) {
        self.albumType = albumType
        self.shortlist = shortlist
    }
    
    var body: some View {
        ProgressView()
            .task {
                switch albumType {
                case .musicKit(let album):
                    await self.viewModel.loadTracks(for: album, shortlist: shortlist)
                
                case .shortlistAlbum(let shortlistAlbum):
                    await self.viewModel.getAlbum(
                        shortListAlbum: shortlistAlbum,
                        shortlist: shortlist
                    )
                }
            }
            .opacity(viewModel.album == nil ? 1 : 0)
        if let album = viewModel.album {
            AlbumView(album: album, shortlist: shortlist)
        }
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let recordID1 = CKRecord.ID(recordName: "uniqueRecordName1")
        let record1 = CKRecord(recordType: "Shortlists", recordID: recordID1)
        record1.setValue("Shortlist One", forKey: "name")
        record1.setValue("All", forKey: "year")
        let shortlist1 = Shortlist(with: record1)!

        let album = AlbumDetailView.Content(
            id: "666",
            artist: "Panda Bear and Sonic Boom",
            artworkURL: URL(string: "https://is3-ssl.mzstatic.com/image/thumb/Music112/v4/07/89/c6/0789c6e0-5dad-404c-ac40-9603659dab77/887828051366.png/390x390bb.jpg"),
            title: "Reset",
            upc: "666",
            trackDetails: [
                AlbumDetailView.Content.TrackDetails(title: "Gettin' to the Point", duration: "2:30"),
                AlbumDetailView.Content.TrackDetails(title: "Go On", duration: "4:46"),
                AlbumDetailView.Content.TrackDetails(title: "Everyday", duration: "3:52"),
                AlbumDetailView.Content.TrackDetails(title: "Edge of the Edge", duration: "4:48"),
                AlbumDetailView.Content.TrackDetails(title: "In My Body", duration: "3:51"),
                AlbumDetailView.Content.TrackDetails(title: "Whirlpool", duration: "5:01"),
                AlbumDetailView.Content.TrackDetails(title: "Danger", duration: "5:38"),
                AlbumDetailView.Content.TrackDetails(title: "Livin' in the After", duration: "2:54"),
                AlbumDetailView.Content.TrackDetails(title: "Everything's Been Leading to This", duration:"5:08")
            ]
        )

        return AlbumDetailView.AlbumView(album: album, shortlist: shortlist1)
    }
}
