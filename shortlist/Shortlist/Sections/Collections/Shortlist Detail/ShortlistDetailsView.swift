//
//  ShortlistDetailsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import CloudKit
import SwiftUI

struct ShortlistDetailsView: View {
    @State private var isPresented = false
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
                            AsyncImage(url: URL(string: album.artworkURLString)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(20)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding(.bottom, 10)
                            
                            Text(album.title)
                                .lineLimit(2)
                            Text(album.artist)
                                .lineLimit(1)
                            Spacer()
                        }
                        .overlay(
                              RoundedRectangle(cornerRadius: 20)
                                  .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 1)
                              )
                        .padding(.bottom, 20)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        
                    }
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
