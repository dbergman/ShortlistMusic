//
//  ShortlistDetailsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import CloudKit
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
                        VStack {
                            ZStack(alignment: .bottomLeading) {
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
                                        .foregroundColor(.blue)
                                        .frame(width: 22, height: 22)
                                    
                                    Text("\(album.rank)")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .bold, design: .default))
                                }
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
                            }
                            .padding(.bottom, 10)
                            
                            Text(album.title)
                                .lineLimit(2)
                            Text(album.artist)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10))
                        .onDrag {
                            draggedAlbumId = album.id
                            return NSItemProvider(item: nil, typeIdentifier: album.id)
                        }
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: MyDropDelegate(
                            item: album.id,
                            items: $viewModel.shortlist.albums,
                            draggedItem: $draggedAlbumId
                        )
                    )
                }
            }
        }
        Spacer()
        ShortlistToolbar()
            .padding(.bottom)
            .navigationBarTitle(viewModel.shortlist.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Image(systemName: "magnifyingglass")
                .onTapGesture {
                    isPresented.toggle()
                }.fullScreenCover(isPresented: $isPresented, onDismiss: {
                    viewModel.getAlbums(for: viewModel.shortlist)
                }, content: {
                    SearchMusicView(isPresented: $isPresented, shortlist: viewModel.shortlist)
                })
            )
            .onAppear() {
                Task {
                    viewModel.getAlbums(for: viewModel.shortlist)
                }
            }
    }
}

struct ShortlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        return ShortlistDetailsView(shortlist: TestData.ShortLists.shortList)
    }
}

struct MyDropDelegate: DropDelegate {
    let item: String
    @Binding var items: [ShortlistAlbum]?
    @Binding var draggedItem: String?
    
    func performDrop(info: DropInfo) -> Bool {
        guard
            let items = items,
            items.count < 1
        else { return false }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard
            let draggedItem = self.draggedItem
        else { return }
        
        if draggedItem != item {
            guard
                let from = items?.firstIndex(where: { $0.id == draggedItem }),
                let to = items?.firstIndex(where: { $0.id == item })
            else { return }
            
            withAnimation(.default) {
                items?.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}
