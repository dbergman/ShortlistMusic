//
//  Shortlist.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/4/23.
//

import CloudKit
import Foundation

struct Shortlist {
    var name: String
    var year: String
    
    init(name: String, year: String) {
        self.name = name
        self.year = year
    }
}
