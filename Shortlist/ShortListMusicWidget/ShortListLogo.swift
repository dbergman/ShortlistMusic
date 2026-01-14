//
//  ShortListLogo.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import SwiftUI
import WidgetKit
import UIKit

struct ShortListLogo: View {
    var size: CGFloat = 100
    
    var body: some View {
        // Render PDFs at specific size to avoid widget size limit issues
        // This ensures images are rendered at the correct size, not at PDF's full resolution
        Group {
            if let recordPlayerImage = renderImage(named: "RecordPlayer", size: size),
               let recordBarsImage = renderImage(named: "RecordBars", size: size) {
                Image(uiImage: recordPlayerImage)
                    .overlay(
                        Image(uiImage: recordBarsImage)
                    )
            } else {
                // Fallback to original approach if rendering fails
                Image("RecordPlayer")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .overlay(
                        Image("RecordBars")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size, height: size)
                    )
            }
        }
        .frame(width: size, height: size)
    }
    
    /// Renders a PDF image asset at a specific size to avoid widget size limits
    /// This ensures the image is rendered at the target size, not at the PDF's full resolution
    /// Widgets have a max image area of ~375,161 pixels
    /// We use 5x scale for maximum quality while staying well under the limit
    /// Example: 30pt @ 5x = 150x150 pixels = 22,500 pixels (only ~6% of limit)
    private func renderImage(named: String, size: CGFloat) -> UIImage? {
        guard let image = UIImage(named: named) else { return nil }
        
        // Target size in points (widgets use points, not pixels)
        let targetSize = CGSize(width: size, height: size)
        
        // Use 5x scale for maximum quality - we have plenty of room under the limit
        // This gives us 150x150 pixels for a 30pt logo, which is excellent quality
        let format = UIGraphicsImageRendererFormat()
        format.scale = 5.0
        format.opaque = false // Allow transparency for PDF overlays
        format.preferredRange = .standard // Use standard color range for best compatibility
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { context in
            // Enable high-quality interpolation for smooth rendering
            context.cgContext.interpolationQuality = .high
            context.cgContext.setShouldAntialias(true)
            context.cgContext.setAllowsAntialiasing(true)
            
            // Draw the image scaled to fit the target size with maximum quality
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
