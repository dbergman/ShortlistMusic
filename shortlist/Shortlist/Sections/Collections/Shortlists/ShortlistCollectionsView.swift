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
                    CreateShortlistView(isPresented: $isPresented)
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
                        NavigationLink(destination: ShortlistDetailsView()) {
                            Text(shortlist.name)
                                .padding(.leading, 12)
                             Spacer()
                                .frame(height: 50)
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
        let recordID1 = CKRecord.ID(recordName: "uniqueRecordName1")
        let record1 = CKRecord(recordType: "Shortlists", recordID: recordID1)
        record1.setValue("Shortlist One", forKey: "name")
        record1.setValue("All", forKey: "year")
        let shortlist1 = Shortlist(with: record1)!
        
        let recordID2 = CKRecord.ID(recordName: "uniqueRecordName2")
        let record2 = CKRecord(recordType: "Shortlists", recordID: recordID2)
        record2.setValue("Shortlist Two", forKey: "name")
        record2.setValue("All", forKey: "year")
        let shortlist2 = Shortlist(with: record2)!
        
        let recordID3 = CKRecord.ID(recordName: "uniqueRecordName3")
        let record3 = CKRecord(recordType: "Shortlists", recordID: recordID3)
        record3.setValue("Shortlist Three", forKey: "name")
        record3.setValue("All", forKey: "year")
        let shortlist3 = Shortlist(with: record3)!
        
        return ShortlistCollectionsView.CollectionsView(
            viewModel: ShortlistCollectionsView.ViewModel(
                shortlists: [shortlist1, shortlist2, shortlist3]
            )
        )
    }
}
