//
//  ShortlistToolbar.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/23/23.
//

import SwiftUI

struct ShortlistToolbar: View {
    @State private var isEditShortlistViewPresented = false
    @State var shortlist: Shortlist

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                // button action 1
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            }
            Spacer()
            Button(action: {
                // button action 2
            }) {
                Image(systemName: "list.number")
                    .font(.title2)
            }
            Spacer()
            Button(action: {
                isEditShortlistViewPresented.toggle()
            }) {
                Image(systemName: "pencil")
                    .font(.title2)
            }
            .sheet(isPresented: $isEditShortlistViewPresented) {
                EditShortlistView(
                    isPresented: $isEditShortlistViewPresented,
                    shortlist: $shortlist,
                    shortlistName: shortlist.name,
                    selectedYear: shortlist.year)
                .presentationDetents([.medium, .large])
            }
            Spacer()
            Button(action: {
                // button action 4
            }) {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
            }
            Spacer()
        }
    }
}


//struct ShortlistToolbar_Previews: PreviewProvider {
//    static var previews: some View {
//        return ShortlistToolbar()
//    }
//}
