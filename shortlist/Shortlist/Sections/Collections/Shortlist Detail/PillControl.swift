//
//  PillControl.swift
//  Shortlist
//
//  Created by Dustin Bergman on 7/5/25.
//

import SwiftUI

struct PillControl: View {
    var onEdit: () -> Void
    var onShare: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .padding(12)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
                            .overlay(
                                Circle()
                                    .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 1)
                            )
                    )
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .clipShape(Circle())
            }

            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .padding(12)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
                            .overlay(
                                Circle()
                                    .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 1)
                            )
                    )
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                .overlay(
                    Capsule()
                        .stroke(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.separator), lineWidth: 1)
                )
        )
        .clipShape(Capsule())
        .shadow(
            color: colorScheme == .dark ? 
                Color.black.opacity(0.6) : 
                Color.black.opacity(0.15),
            radius: colorScheme == .dark ? 12 : 8,
            x: 0,
            y: colorScheme == .dark ? 6 : 4
        )
    }
}
