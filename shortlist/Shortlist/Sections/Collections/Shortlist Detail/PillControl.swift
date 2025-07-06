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

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .padding(12)
                    .background(Color(white: 0.9))
                    .foregroundColor(.black)
                    .clipShape(Circle())
            }

            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .padding(12)
                    .background(Color(white: 0.9))
                    .foregroundColor(.black)
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(radius: 4)
    }
}
