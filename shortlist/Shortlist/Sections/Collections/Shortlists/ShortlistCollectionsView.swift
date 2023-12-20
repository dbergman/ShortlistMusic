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
                                Text(shortlist.name)
                                HStack {
                                    if
                                        let firstAlbum = shortlist.albums?.first,
                                        let firstAlbumArt = firstAlbum.artworkURL
                                    {
                                        AsyncImage(url: firstAlbumArt) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(10)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    
                                    HStack(spacing: 10) {
                                        VStack(spacing: 10) {
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
