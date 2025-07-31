//
//  ImageGridCreator.swift
//  Shortlist
//
//  Created by Dustin Bergman on 7/16/25.
//

import UIKit

class ImageGridCreator {
    /// Asynchronously creates a perfect square grid image from an array of images.
    /// - Parameters:
    ///   - images: Array of square `UIImage` objects.
    ///   - outputSize: The desired size of the output square image.
    /// - Returns: A `UIImage` representing the square grid, or `nil` if the input array is empty.
    func createSquareImageGrid(from images: [UIImage], outputSize: CGSize) async -> UIImage? {
        guard !images.isEmpty else { return nil }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let count = images.count
                let gridSize = Int(ceil(sqrt(Double(count))))
                let cellSize = outputSize.width / CGFloat(gridSize)

                UIGraphicsBeginImageContextWithOptions(outputSize, false, 0)

                for (index, image) in images.enumerated() {
                    let row = index / gridSize
                    let col = index % gridSize

                    let rect = CGRect(x: CGFloat(col) * cellSize,
                                      y: CGFloat(row) * cellSize,
                                      width: cellSize,
                                      height: cellSize)
                    image.draw(in: rect)
                }

                let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                continuation.resume(returning: finalImage)
            }
        }
    }
}
