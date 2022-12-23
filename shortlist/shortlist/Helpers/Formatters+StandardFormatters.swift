//
//  Formatters+StandardFormatters.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/22/22.
//

import Foundation

extension DateFormatter {
    public static let airdateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
}
