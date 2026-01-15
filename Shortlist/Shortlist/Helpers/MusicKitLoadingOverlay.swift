//
//  MusicKitLoadingOverlay.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/13/26.
//

import SwiftUI

struct MusicKitLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                SpinningRecordView(size: 80, color: .blue)
                Text("Opening Apple Music...")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Please wait...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            )
        }
    }
}

