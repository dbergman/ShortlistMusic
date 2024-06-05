//
//  UserErrorFactory.swift
//  Shortlist
//
//  Created by Dustin Bergman on 6/4/24.
//

import Foundation

enum UserError: Int {
    case userNotFound
    case invalidUserID
    case unknown

    var localizedDescription: String {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidUserID:
            return "Invalid user ID"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

struct UserErrorFactory {
    static let errorDomain = "com.dus.shortList"

    static func makeError(_ error: UserError) -> NSError {
        return NSError(domain: errorDomain, code: error.rawValue, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
    }
}
