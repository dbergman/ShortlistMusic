//
//  Theme.swift
//  Shortlist
//
//  Created by Dustin Bergman on 4/6/25.
//


import SwiftUI

class Theme {
    static let shared = Theme()

    // MARK: - Colors
    var primary: Color {
        // Use named color from assets with fallback for widget/extensions
        if let color = UIColor(named: "PrimaryColor") {
            return Color(color)
        }
        return Color.blue
    }

    var secondary: Color {
        if let color = UIColor(named: "SecondaryColor") {
            return Color(color)
        }
        return Color.gray.opacity(0.3)
    }

    var background: Color {
        if let color = UIColor(named: "BackgroundColor") {
            return Color(color)
        }
        return Color(.systemBackground)
    }

    var text: Color {
        if let color = UIColor(named: "TextColor") {
            return Color(color)
        }
        return Color(.label)
    }

    // MARK: - Fonts
    func avenir(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("Avenir-Heavy", size: size)
        case .medium:
            return .custom("Avenir-Medium", size: size)
        case .light:
            return .custom("Avenir-Light", size: size)
        default:
            return .custom("Avenir-Book", size: size)
        }
    }

    func avenirUIFont(size: CGFloat, weight: Font.Weight = .regular) -> UIFont {
        let name: String
        switch weight {
        case .bold:
            name = "Avenir-Heavy"
        case .medium:
            name = "Avenir-Medium"
        case .light:
            name = "Avenir-Light"
        default:
            name = "Avenir-Book"
        }

        return UIFont(name: name, size: size)!
    }
}
