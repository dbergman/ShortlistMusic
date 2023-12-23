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
                .navigationTitle("My ShortLists")
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
     
                                    VStack {
                                        Grid {
                                            GridRow {
                                                loadImage(from: shortlist, with: 1)
                                                loadImage(from: shortlist, with: 2)
                                            }
                                            GridRow {
                                                loadImage(from: shortlist, with: 3)
                                                loadImage(from: shortlist, with: 4)
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
        
        @ViewBuilder
        private func loadImage(from shortlist: Shortlist, with index: Int) -> some View {
            if
                let shortlistAlbums = shortlist.albums,
                shortlistAlbums.count > index,
                let artworkURLString = shortlist.albums?[index].artworkURLString,
                let url = URL(string: artworkURLString)
            {
                AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(10)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                            }
            }
        }
        
        func randomColor() -> Color {
            let red = Double.random(in: 0...1)
            let green = Double.random(in: 0...1)
            let blue = Double.random(in: 0...1)
            
            return Color(red: red, green: green, blue: blue)
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
                shortlists: [shortlist, shortlist, shortlist]
            )
        )
    }
}
