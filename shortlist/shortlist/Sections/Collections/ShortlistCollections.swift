//
//  ShortlistCollections.swift
//  shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SwiftUI

struct ShortlistCollections: View {
    var body: some View {
        NavigationView {
            Text("")
                .navigationTitle("ShortListMusic")
                .toolbar {
                    Button {
                        print("Search")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
        }
    }
}

struct ShortlistCollections_Previews: PreviewProvider {
    static var previews: some View {
        ShortlistCollections()
    }
}
