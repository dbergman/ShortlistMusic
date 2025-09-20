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
        Color("PrimaryColor")
    }

    var secondary: Color {
        Color("SecondaryColor")
    }

    var background: Color {
        Color("BackgroundColor")
    }

    var text: Color {
        Color("TextColor")
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
