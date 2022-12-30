//
//  ShortlistCollectionsView.swift
//  shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

struct ShortlistCollectionsView: View {
    @State var isPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
               VStack(alignment: .leading) {
                   HStack {
                       NavigationLink(destination: ShortlistDetailsView()) {
                           Text("ShortList One")
                               .padding(.leading, 12)

                           Spacer().frame(height: 50)
                       }
                   }
                   .contentShape(Rectangle())
                   
                   HStack {
                       Text("ShortList Two")
                           .padding(.leading, 12)
                       Spacer().frame(height: 50)
                   }
                   .contentShape(Rectangle())
                   .onTapGesture {
                       print("TAP TAP TAP")
                   }
                   
                   HStack {
                       Text("ShortList Three")
                           .padding(.leading, 12)
                       Spacer().frame(height: 50)
                   }
                   .contentShape(Rectangle())
                   .onTapGesture {
                       print("TAP TAP TAP")
                   }
               }
            }
            .onAppear(perform: MusicPermission.shared.beginObservingMusicAuthorizationStatus)
                .navigationTitle("ShortListMusic")
                .toolbar {
                    Button {
                        self.isPresented.toggle()
                    } label: {
                        Image(systemName: "doc")
                    }
                }
                .welcomeSheet()
        }
        .sheet(isPresented: $isPresented) {
            CreateShortlistView(isPresented: $isPresented)
                .presentationDetents([.medium, .large])
        }
    }
}

struct ShortlistCollections_Previews: PreviewProvider {
    static var previews: some View {
        ShortlistCollectionsView()
    }
}
