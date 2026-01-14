//
//  ShortListLogoBadge.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import SwiftUI

struct ShortListLogoBadge: View {
    var logoSize: CGFloat = 26
    var horizontalPadding: CGFloat = 2
    var verticalPadding: CGFloat = 1
    var spacing: CGFloat = -2
    var fontSize: CGFloat = 10
    var kerning: CGFloat = 1.0
    
    var body: some View {
        // Ensure logo is properly sized to avoid widget size limit issues
        ShortListLogo(size: logoSize)
            .frame(width: logoSize, height: logoSize)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
    }
}

