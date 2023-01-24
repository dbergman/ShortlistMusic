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
    private var shortlist: Shortlist
    
    init(isPresented: Bool = false, shortlist: Shortlist) {
        self.isPresented = isPresented
        self.shortlist = shortlist
    }
    
    var body: some View {
        VStack {
            Text("List of Albums")
            Spacer()
            ShortlistToolbar()
                .padding(.bottom)
                .navigationBarTitle(shortlist.name)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Image(systemName: "magnifyingglass")
                    .onTapGesture {
                        isPresented.toggle()
                    }.fullScreenCover(isPresented: $isPresented, content: {
                        SearchMusicView(isPresented: $isPresented)
                    })
                )
        }
        
        
        
    }
}

struct ShortlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        let recordID1 = CKRecord.ID(recordName: "uniqueRecordName1")
        let record1 = CKRecord(recordType: "Shortlists", recordID: recordID1)
        record1.setValue("Shortlist One", forKey: "name")
        record1.setValue("All", forKey: "year")
        let shortlist1 = Shortlist(with: record1)!
        
        return ShortlistDetailsView(shortlist: shortlist1)
    }
}