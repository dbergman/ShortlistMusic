//
//  ShortlistDetailsView.swift
//  shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

struct ShortlistDetailsView: View {
    @State private var isPresented = false
    
    var body: some View {
        Text("List of Albums")
        .navigationBarTitle("A Shortlist")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Image(systemName: "magnifyingglass")
            .onTapGesture {
                isPresented.toggle()
            }.fullScreenCover(isPresented: $isPresented, content: {
                SearchMusicKit(isPresented: $isPresented)
            })
        )
    }
}

struct ShortlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        ShortlistDetailsView()
    }
}
