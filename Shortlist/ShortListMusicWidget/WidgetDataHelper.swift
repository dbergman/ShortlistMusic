//
//  WidgetDataHelper.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import WidgetKit
import UIKit
import os

let logger = Logger(subsystem: "com.dus.shortList.dev.ShortListMusicWidgetExtension", category: "Widget")

/// Helper methods for retrieving and processing widget data
struct WidgetDataHelper {
    
    // MARK: - Data Retrieval
    
    /// Fetches albums from CloudKit for a specific widget family
    /// - Parameters:
    ///   - family: The widget family (small, medium, large)
    ///   - completion: Completion handler with fetched albums
    static func fetchAlbums(for family: WidgetFamily, completion: @escaping ([ShortlistAlbum]) -> Void) {
        logger.debug("Widget: Starting CloudKit fetch for \(family) widget...")
        
        WidgetCloudKitManager.shared.getAllAlbums { result in
            logger.debug("Widget: CloudKit fetch completed with result")
            
            switch result {
            case .success(let allAlbums):
                logger.debug("Widget: Successfully fetched \(allAlbums.count) albums from CloudKit")

                if allAlbums.isEmpty {
                    logger.debug("Widget: CloudKit returned empty album array - this might mean no data or user not signed in")
                    completion([])
                    return
                }

                // Determine album count based on widget family
                let albumCount = getAlbumCount(for: family)
                
                logger.debug("Widget: Requesting \(albumCount) albums for \(family) widget from \(allAlbums.count) available albums")

                // Shuffle and take exactly the required number of albums
                let shuffledAlbums = allAlbums.shuffled()
                let selectedAlbums = Array(shuffledAlbums.prefix(albumCount))

                logger.debug("Widget: Selected \(selectedAlbums.count) albums for \(family) widget (requested \(albumCount))")
                if selectedAlbums.count > 0 {
                    logger.debug("Widget: Selected albums: \(selectedAlbums.map { "\($0.title) by \($0.artist)" })")
                }
                completion(selectedAlbums)

            case .failure(let error):
                logger.debug("Widget: Failed to fetch albums: \(error.localizedDescription)")
                logger.debug("Widget: Error details: \(error)")
                logger.debug("Widget: Error domain: \(error._domain), code: \(error._code)")
                // Return empty array on error - timeline will use sample data
                completion([])
            }
        }
    }
    
    // MARK: - Image Preloading
    
    /// Preloads album artwork images for widget display
    /// Images are requested at 60x60 pixels directly from Apple Music CDN to avoid resizing
    /// - Parameters:
    ///   - albums: Array of albums to preload images for
    ///   - completion: Completion handler with dictionary of album ID to UIImage
    static func preloadImages(for albums: [ShortlistAlbum], completion: @escaping ([String: UIImage]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var images: [String: UIImage] = [:]
        let lock = NSLock()
        
        logger.debug("Widget: Preloading images for \(albums.count) albums")
        
        for album in albums {
            guard !album.artworkURLString.isEmpty else {
                logger.debug("Widget: Skipping album with empty artwork URL: \(album.title)")
                continue
            }
            
            // Resize URL to request 60x60 image directly from Apple Music CDN
            let resizedURLString = resizeArtworkURL(album.artworkURLString, size: 60)
            guard let url = URL(string: resizedURLString),
                  (url.scheme == "https" || url.scheme == "http") else {
                logger.debug("Widget: Skipping invalid artwork URL for \(album.title): \(album.artworkURLString)")
                continue
            }
            
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    logger.debug("Widget: Failed to download image for \(album.title): \(error.localizedDescription)")
                    return
                }
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    logger.debug("Widget: Failed to create image from data for \(album.title)")
                    return
                }
                
                // Image is already 60x60 from CDN, just cache it
                lock.lock()
                images[album.id] = image
                lock.unlock()
                
                // Log image information for debugging
                if let cgImage = image.cgImage {
                    logger.debug("Widget: Successfully loaded image for \(album.title) - CGImage pixels: \(cgImage.width)x\(cgImage.height), scale: \(image.scale)")
                } else {
                    logger.debug("Widget: Successfully loaded image for \(album.title) - size: \(image.size.width)x\(image.size.height)")
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            logger.debug("Widget: Finished preloading images. Got \(images.count) images out of \(albums.count) albums")
            completion(images)
        }
    }
    
    // MARK: - Utility Methods
    
    /// Returns the number of albums to display for a given widget family
    /// - Parameter family: The widget family
    /// - Returns: Number of albums to display
    static func getAlbumCount(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall:
            return 1
        case .systemMedium:
            return 3
        case .systemLarge:
            return 6
        @unknown default:
            return 1
        }
    }
    
    /// Resizes Apple Music artwork URL to request a specific size from CDN
    /// Apple Music URLs support size parameters: /SIZExSIZEbb.jpg
    /// - Parameters:
    ///   - urlString: The original artwork URL string
    ///   - size: Desired size in pixels (default 60)
    /// - Returns: Modified URL string with requested size, or original if not Apple Music URL
    static func resizeArtworkURL(_ urlString: String, size: Int = 60) -> String {
        guard urlString.contains("mzstatic.com") else {
            // Return original URL if not from Apple Music CDN
            return urlString
        }
        
        // Replace size parameter: /SIZExSIZEbb.jpg with /NEWSIZExNEWSIZEbb.jpg
        // Pattern matches: /402x402bb.jpg, /300x300bb.jpg, etc.
        if let range = urlString.range(of: "/\\d+x\\d+bb\\.jpg", options: .regularExpression) {
            return urlString.replacingCharacters(in: range, with: "/\(size)x\(size)bb.jpg")
        }
        
        // If pattern not found, return original URL
        return urlString
    }
    
    /// Resizes background image to widget size
    /// WidgetKit has strict size limits, so we ensure images don't exceed reasonable widget dimensions
    /// - Parameters:
    ///   - image: The background image
    ///   - targetSize: Target size for the widget
    /// - Returns: Resized image
    static func resizeBackgroundImageForWidget(_ image: UIImage, targetSize: CGSize) -> UIImage {
        // Limit maximum dimensions to prevent exceeding widget size limits
        // WidgetKit max render size is approximately 1084x986, but we'll be more conservative
        let maxWidth: CGFloat = 400
        let maxHeight: CGFloat = 400
        
        // Calculate constrained size that fits within max dimensions while maintaining aspect ratio
        let constrainedSize: CGSize
        if targetSize.width > maxWidth || targetSize.height > maxHeight {
            let aspectRatio = targetSize.width / targetSize.height
            if targetSize.width > targetSize.height {
                // Landscape: constrain width
                constrainedSize = CGSize(width: min(targetSize.width, maxWidth), height: min(targetSize.width, maxWidth) / aspectRatio)
            } else {
                // Portrait or square: constrain height
                constrainedSize = CGSize(width: min(targetSize.height, maxHeight) * aspectRatio, height: min(targetSize.height, maxHeight))
            }
        } else {
            constrainedSize = targetSize
        }
        
        // If image is already smaller than constrained size, return as-is
        if image.size.width <= constrainedSize.width && image.size.height <= constrainedSize.height {
            return image
        }
        
        // Render resized image with scale factor 1.0 to reduce memory footprint
        UIGraphicsBeginImageContextWithOptions(constrainedSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: constrainedSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
}

