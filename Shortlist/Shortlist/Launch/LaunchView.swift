//
//  LaunchVIew.swift
//  Shortlist
//
//  Created by Dustin Bergman on 9/13/25.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image that fills the entire screen
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // RecordPlayer image centered relative to background
                Image("RecordPlayer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.87)
                    .frame(height: geometry.size.width * 0.87)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2 + 15
                    )
                
                // RecordBars image layered on top of RecordPlayer
                Image("RecordBars")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.87)
                    .frame(height: geometry.size.width * 0.87)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2 + 15
                    )
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    LaunchView()
}
