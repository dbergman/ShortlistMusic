//
//  MusicKit+Extension.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/27/22.
//

import Foundation
import MusicKit

extension Album {
    var releaseYear: String {
        guard let releaseDate = releaseDate else { return "" }

        let calendar = Calendar(identifier: .gregorian)
        
        return "\(calendar.component(.year, from: releaseDate))"
    }
}

extension Track {
    var displayDuration: String {
        guard let duration = duration else { return "" }

        return DateFormatter.durationFormatter.string(from: duration) ?? ""
    }
}
