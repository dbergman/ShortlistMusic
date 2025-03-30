//
//  ShortlistCollectionsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SkeletonUI
import SwiftUI

struct ShortlistCollectionsView: View {
    @State var isPresented = false
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            CollectionsView(viewModel: viewModel)
                .navigationTitle("My Shortlists")
                .task {
                    await MusicPermission.shared.requestMusicKitAuthorization()
                }
                .toolbar {
                    Button {
                        self.isPresented.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .tint(.black)
                    }
                }
                .onBoardingSheet()
                .sheet(isPresented: $isPresented) {
                    CreateShortlistView(isPresented: $isPresented, shortlists: $viewModel.shortlists)
                        .presentationDetents([.medium, .large])
                }.onAppear() {
                    Task {
                        try? await viewModel.getShortlists()
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
            } else {
                List {
                    ForEach(viewModel.shortlists, id: \.self) { shortlist in
                        Section {
                            HStack {
                                NavigationLink(destination: ShortlistDetailsView(shortlist: shortlist)) {
                                    VStack {
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
                                        HStack {
                                            Text(shortlist.name)
                                            Spacer()
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
            let size: CGFloat = index == 0 ? 150 :70
    
            if
                let shortlistAlbums = shortlist?.albums,
                shortlistAlbums.count > index,
                let artworkURLString = shortlist?.albums?[index].artworkURLString,
                let url = URL(string: artworkURLString)
            {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    placeHolderRect(with: size)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: size, height: size)
                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .foregroundColor(.gray)
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
                                HStack {
                                    Text("Shortlist Name")
                                    Spacer()
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
            guard let index = offsets.first else { return }

            let shortlist = viewModel.shortlists[index]

            Task {
                try? await viewModel.remove(shortlist: shortlist)
            }
            
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
