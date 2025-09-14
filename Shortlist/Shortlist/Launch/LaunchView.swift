//
//  LaunchVIew.swift
//  Shortlist
//
//  Created by Dustin Bergman on 9/13/25.
//

import SwiftUI

struct LaunchView: View {
    @State private var rotationAngle: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: Double = 20
    
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
                
                // RecordBars image layered on top of RecordPlayer with continuous spinning
                Image("RecordBars")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.87)
                    .frame(height: geometry.size.width * 0.87)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2 + 15
                    )
                    .rotationEffect(.degrees(rotationAngle))
                    .onAppear {
                        // Delay start by 0.3 seconds, then spin continuously
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                    }
                
                // Shortlist Music text with animation
                Text("Shortlist Music")
                    .font(Theme.shared.avenir(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2 + 15 + (geometry.size.width * 0.87) / 2 + 40
                    )
                    .onAppear {
                        // Animate text appearance after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeOut(duration: 0.8)) {
                                textOpacity = 1.0
                                textOffset = 0
                            }
                        }
                    }
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    LaunchView()
}
