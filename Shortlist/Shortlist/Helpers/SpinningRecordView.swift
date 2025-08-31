//
//  SpinningRecordView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 8/30/25.
//

import SwiftUI

struct SpinningRecordView: View {
    @State private var isSpinning = false
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 40, color: Color = .blue) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            // Main record background
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size, height: size)
            
            // Inner record circle
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: size * 0.8, height: size * 0.8)
            
            // Center hole
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.2, height: size * 0.2)
            
            // Groove lines (simulating vinyl record grooves)
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: size * (0.3 + Double(index) * 0.05), height: size * (0.3 + Double(index) * 0.05))
            }
            
            // Spinning music note symbol in the center - this will make rotation obvious
            Image(systemName: "music.note")
                .font(.system(size: size * 0.2, weight: .bold))
                .foregroundColor(color)
                .rotationEffect(.degrees(isSpinning ? 360 : 0))
                .animation(
                    .linear(duration: 0.8)
                    .repeatForever(autoreverses: false),
                    value: isSpinning
                )
        }
        .onAppear {
            isSpinning = true
        }
    }
}

struct SpinningRecordView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SpinningRecordView(size: 40, color: .blue)
            SpinningRecordView(size: 50, color: .red)
            SpinningRecordView(size: 60, color: .green)
        }
        .padding()
    }
}
