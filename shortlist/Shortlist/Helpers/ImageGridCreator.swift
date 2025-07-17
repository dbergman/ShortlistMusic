//
//  ImageGridCreator.swift
//  Shortlist
//
//  Created by Dustin Bergman on 7/16/25.
//

import UIKit

class ImageGridCreator {
    /// Creates a perfect square grid image from an array of images.
    /// - Parameters:
    ///   - images: Array of square `UIImage` objects.
    ///   - outputSize: The desired size of the output square image.
    /// - Returns: A `UIImage` representing the square grid, or `nil` if the input array is empty.
    func createSquareImageGrid(from images: [UIImage], outputSize: CGSize) -> UIImage? {
        guard !images.isEmpty else { return nil }
        
        // Calculate the grid size (rows and columns)
        let count = images.count
        let gridSize = Int(ceil(sqrt(Double(count))))
        let cellSize = outputSize.width / CGFloat(gridSize)
        
        // Create a graphics context
        UIGraphicsBeginImageContextWithOptions(outputSize, false, 0)
        
        // Fill the grid with images
        for (index, image) in images.enumerated() {
            let row = index / gridSize
            let col = index % gridSize
            
            let rect = CGRect(x: CGFloat(col) * cellSize,
                              y: CGFloat(row) * cellSize,
                              width: cellSize,
                              height: cellSize)
            
            // Draw the image in its cell
            image.draw(in: rect)
        }
        
        // Get the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
}
