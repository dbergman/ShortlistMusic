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
            if viewModel.isloading {
                loadingPlaceholder()
                //TestSwiftUI()
            } else {
                List {
                    ForEach(viewModel.shortlists, id: \.self) { shortlist in
                        Section {
                            HStack {
                                NavigationLink(destination: ShortlistDetailsView(shortlist: shortlist)) {
                                    VStack {
                                        HStack {
                                            Text(shortlist.name)
                                            Spacer()
                                        }
                                        HStack {
                                            loadImage(from: shortlist, with: 0)
                                            
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
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        
        @ViewBuilder
        private func loadImage(from shortlist: Shortlist?, with index: Int) -> some View {
            if
                let shortlistAlbums = shortlist?.albums,
                shortlistAlbums.count > index,
                let artworkURLString = shortlist?.albums?[index].artworkURLString,
                let url = URL(string: artworkURLString)
            {
                AsyncImage(url: url) { image in
                    let size: CGFloat = index == 0 ? 150 :70
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    placeHolderRect(with: index == 0 ? 150 :70)
                }
            }
        }
        
        @ViewBuilder
        private func loadingPlaceholder() -> some View {
            List {
                ForEach(0..<3) { _ in
                    Section {
                        HStack {
                            VStack {
                                HStack {
                                    Text("Shortlist Name")
                                    Spacer()
                                    Text("year")
                                        .padding(.trailing, 10)
                                }
                                HStack {
                                    placeHolderRect(with: 150)
                                    VStack {
                                        Grid {
                                            GridRow {
                                                placeHolderRect(with: 70)
                                                placeHolderRect(with: 70)
                                            }
                                            GridRow {
                                                placeHolderRect(with: 70)
                                                placeHolderRect(with: 70)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .redacted(reason: .placeholder)
                }
            }
        }
        
        @ViewBuilder
        private func placeHolderRect(with size: CGFloat) -> some View {
            Rectangle()
                .scaledToFit()
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                .cornerRadius(10)
                .frame(width: size, height: size)
        }
        
        private func delete(at offsets: IndexSet) {
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
