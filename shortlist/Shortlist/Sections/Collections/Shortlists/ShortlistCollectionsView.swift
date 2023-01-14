//
//  ShortlistCollectionsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

struct ShortlistCollectionsView: View {
    @State var isPresented = false
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            CollectionsView(shortlists: viewModel.shortlists)
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
        private var shortlists: [String]

        init(shortlists: [String]?) {
            self.shortlists = shortlists ?? []
        }

        var body: some View {
            List {
                ForEach(shortlists, id: \.self) { shortlist in
                    HStack {
                        NavigationLink(destination: ShortlistDetailsView()) {
                            Text(shortlist)
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
            print()
        }
    }
}

//struct ShortlistCollections_Previews: PreviewProvider {
//    static var previews: some View {
//        ShortlistCollectionsView.CollectionsView()
//    }
//}
