//
//  ShortlistCollectionsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

struct ShortlistCollectionsView: View {
    @State var isPresented = false

    var body: some View {
        NavigationStack {
            CollectionsView()
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
                }
        }
    }
}

extension ShortlistCollectionsView {
    struct CollectionsView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        NavigationLink(destination: ShortlistDetailsView()) {
                            Text("ShortList Goes here")
                                .padding(.leading, 12)
                            
                            Spacer().frame(height: 50)
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
        }
    }
}

struct ShortlistCollections_Previews: PreviewProvider {
    static var previews: some View {
        ShortlistCollectionsView.CollectionsView()
    }
}
