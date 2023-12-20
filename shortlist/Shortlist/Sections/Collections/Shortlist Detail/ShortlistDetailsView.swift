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
    
    init(isPresented: Bool = false, shortlist: Shortlist) {
        viewModel = ViewModel.init(shortlist: shortlist)
        self.isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.shortlist.albums ?? [], id: \.self) { album in
                    let albumType = AlbumDetailView.AlbumType.shortlistAlbum(album)
                    NavigationLink(
                        destination: AlbumDetailView(albumType: albumType, shortlist: viewModel.shortlist)
                    ){
                        HStack {
                            Text(album.title)
                                .padding(.leading, 12)
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
        }
        .onAppear() {
            Task {
                viewModel.getAlbums(for: viewModel.shortlist)
            }
        }
    }
}

struct ShortlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        let recordID1 = CKRecord.ID(recordName: "uniqueRecordName1")
        let record1 = CKRecord(recordType: "Shortlists", recordID: recordID1)
        record1.setValue("Shortlist One", forKey: "name")
        record1.setValue("All", forKey: "year")
        record1.setValue(UUID().uuidString, forKey: "id")
        let shortlist1 = Shortlist(with: record1)!
        
        return ShortlistDetailsView(shortlist: shortlist1)
    }
}
