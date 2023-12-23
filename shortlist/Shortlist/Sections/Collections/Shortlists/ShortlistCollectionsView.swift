//
//  ShortlistCollectionsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import CloudKit
import SwiftUI

struct ShortlistCollectionsView: View {
    @State var isPresented = false
    @ObservedObject private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            CollectionsView(viewModel: viewModel)
                .navigationTitle("ShortListMusic")
                .task {
                    await MusicPermission.shared.requestMusicKitAuthorization()
                }
                .toolbar {
                    Button {
                        self.isPresented.toggle()
                    } label: {
                        Image(systemName: "doc")
                    }
                }
                .onBoardingSheet()
                .sheet(isPresented: $isPresented) {
                    CreateShortlistView(isPresented: $isPresented, shortlists: $viewModel.shortlists)
                        .presentationDetents([.medium, .large])
                }.onAppear() {
                    Task {
                        try? viewModel.getShortlists()
                    }
                }
        }
    }
}

extension ShortlistCollectionsView {
    struct CollectionsView: View {
        @ObservedObject private var viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        var body: some View {
            List {
                ForEach(viewModel.shortlists, id: \.self) { shortlist in
                    HStack {
                        NavigationLink(destination: ShortlistDetailsView(shortlist: shortlist)) {
                            VStack {
                                HStack {
                                    Text(shortlist.name)
                                    Spacer()
                                }
                                HStack {
                                    if
                                        let firstAlbum = shortlist.albums?.first,
                                        let firstAlbumArt = URL(string: firstAlbum.artworkURLString)
                                    {
                                        AsyncImage(url: firstAlbumArt) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .cornerRadius(10)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    
                                    HStack {
                                        VStack(spacing: 10) {
                                            ForEach(shortlist.albums?.suffix(2) ?? []) { album in
                                                if let albumArt = URL(string: album.artworkURLString) {
                                                    AsyncImage(url: albumArt) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 70, height: 70)
                                                            .cornerRadius(10)
                                                            .clipped()
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                } else {
                                                    Color.orange
                                                        .frame(width: 70, height: 70)
                                                        .cornerRadius(10)
                                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                                                }
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        VStack(spacing: 10) {
                                            ForEach(shortlist.albums?.suffix(2) ?? []) { album in
                                                if let albumArt = URL(string: album.artworkURLString) {
                                                    AsyncImage(url: albumArt) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 70, height: 70)
                                                            .cornerRadius(10)
                                                            .clipped()
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                } else {
                                                    Color.orange
                                                        .frame(width: 70, height: 70)
                                                        .cornerRadius(10)
                                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                                                }
                                            }
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }
        
        func delete(at offsets: IndexSet) {
            guard
                let index = offsets.first
            else {
                return
            }
            
            let shortlist = viewModel.shortlists[index]
            viewModel.remove(shortlist: shortlist)
        }
    }
}

struct ShortlistCollections_Previews: PreviewProvider {
    static var previews: some View {
        let shortlist = TestData.ShortLists.shortList
        
        return ShortlistCollectionsView.CollectionsView(
            viewModel: ShortlistCollectionsView.ViewModel(
                shortlists: [shortlist]
            )
        )
    }
}
