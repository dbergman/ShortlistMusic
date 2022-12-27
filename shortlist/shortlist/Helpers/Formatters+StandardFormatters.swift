//
//  Formatters+StandardFormatters.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/22/22.
//

import Foundation

extension DateFormatter {
    public static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
}
