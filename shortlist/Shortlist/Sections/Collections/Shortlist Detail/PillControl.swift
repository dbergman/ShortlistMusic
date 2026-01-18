//
//  PillControl.swift
//  Shortlist
//
//  Created by Dustin Bergman on 7/5/25.
//

import SwiftUI

struct PillControl: View {
    var onEdit: () -> Void
    var onSearch: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onSearch) {
                Image(systemName: "plus.magnifyingglass")
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(.quaternary, lineWidth: 0.5)
                            )
                    )
                    .foregroundColor(.primary)
                    .clipShape(Circle())
            }

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(.quaternary, lineWidth: 0.5)
                            )
                    )
                    .foregroundColor(.primary)
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
        .clipShape(Capsule())
    }
}
