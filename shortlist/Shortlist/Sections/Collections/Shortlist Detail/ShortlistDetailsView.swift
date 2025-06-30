//
//  ShortlistDetailsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShortlistDetailsView: View {
    @State private var isPresented = false
    @State var draggedAlbumId: String?
    @ObservedObject private var viewModel: ViewModel
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(isPresented: Bool = false, shortlist: Shortlist) {
        viewModel = ViewModel(shortlist: shortlist)
        self.isPresented = isPresented
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(viewModel.shortlist.albums ?? [], id: \.self) { album in
                    let albumType = AlbumDetailView.AlbumType.shortlistAlbum(album)
                    NavigationLink(
                        destination: AlbumDetailView(albumType: albumType, shortlist: viewModel.shortlist)
                    ){
                        VStack(alignment: .leading) {
                            ZStack(alignment: .topLeading) {
                                AsyncImage(url: URL(string: album.artworkURLString)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(20)
                                } placeholder: {
                                    ProgressView()
                                }

                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.75))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                                        )
                                        .shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 2)

                                    Text("\(album.rank)")
                                        .foregroundColor(.white)
                                        .font(Theme.shared.avenir(size: 14, weight: .bold))
                                }
                                .padding(6)
                            }
                            .padding(.bottom, 10)
                            
                            Text(album.title)
                                .font(Theme.shared.avenir(size: 16, weight: .bold))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                                .lineLimit(2)
                            Text(album.artist)
                                .font(Theme.shared.avenir(size: 14, weight: .medium))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            Spacer()
                        }
                        .frame(height: 230)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .padding(EdgeInsets(top: 0, leading: 6, bottom: 10, trailing: 6))
                        .onDrag {
                            draggedAlbumId = album.id
                            return NSItemProvider(item: nil, typeIdentifier: album.id)
                        }
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: MyDropDelegate(
                            updatedAlbumId: album.id,
                            shortlistAlbums: $viewModel.shortlist.albums,
                            draggedItem: $draggedAlbumId,
                            viewModel: viewModel
                        )
                    )
                }
            }
        }
        Spacer()
        ShortlistToolbar()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.shortlist.name)
                        .font(Theme.shared.avenir(size: 20, weight: .bold))
                }
            }
            .navigationBarItems(trailing: Image(systemName: "magnifyingglass")
                .onTapGesture {
                    isPresented.toggle()
                }.fullScreenCover(isPresented: $isPresented, onDismiss: {
                    Task {
                        try await viewModel.getAlbums(for: viewModel.shortlist)
                    }
                }, content: {
                    SearchMusicView(isPresented: $isPresented, shortlist: viewModel.shortlist)
                })
            )
            .onAppear() {
                Task {
                    try await viewModel.getAlbums(for: viewModel.shortlist)
                }
            }
            .environmentObject(viewModel)
    }
    
    struct MyDropDelegate: DropDelegate {
        let updatedAlbumId: String
        @Binding var shortlistAlbums: [ShortlistAlbum]?
        @Binding var draggedItem: String?
        @ObservedObject var viewModel: ViewModel
        
        func performDrop(info: DropInfo) -> Bool {
            guard let shortlistAlbums = shortlistAlbums else { return true }
            
            Task {
                try await viewModel.updateShortlistAlbumRanking(sortedAlbums: shortlistAlbums)
            }
            
            return true
        }
        
        func dropEntered(info: DropInfo) {
            guard
                let draggedItem = self.draggedItem
            else { return }
            
            if draggedItem != updatedAlbumId {
                guard
                    let from = shortlistAlbums?.firstIndex(where: { $0.id == draggedItem }),
                    let to = shortlistAlbums?.firstIndex(where: { $0.id == updatedAlbumId })
                else { return }
                
                withAnimation(.default) {
                    shortlistAlbums?.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                }
            }
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }
    }
}

struct ShortlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        return ShortlistDetailsView(shortlist: TestData.ShortLists.shortList)
    }
}
