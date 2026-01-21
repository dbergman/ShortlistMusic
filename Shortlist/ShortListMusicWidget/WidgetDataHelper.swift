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

struct WidgetDataHelper {
    private static let artworkSize = 400
    private static let maxImageDimension: CGFloat = 400
    
    static func fetchAlbums(for family: WidgetFamily, completion: @escaping ([ShortlistAlbum]) -> Void) {
        WidgetCloudKitManager.shared.getAllAlbums { result in
            switch result {
            case .success(let allAlbums):
                if allAlbums.isEmpty {
                    completion([])
                    return
                }
                
                let albumCount = getAlbumCount(for: family)
                let selectedAlbums = Array(allAlbums.shuffled().prefix(albumCount))
                completion(selectedAlbums)
                
            case .failure:
                completion([])
            }
        }
    }
    
    static func preloadImages(for albums: [ShortlistAlbum], completion: @escaping ([String: UIImage]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var images: [String: UIImage] = [:]
        let lock = NSLock()
        
        for album in albums {
            guard !album.artworkURLString.isEmpty else { continue }
            
            let resizedURLString = resizeArtworkURL(album.artworkURLString, size: artworkSize)
            guard let url = URL(string: resizedURLString),
                  url.scheme == "https" || url.scheme == "http" else {
                continue
            }
            
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { dispatchGroup.leave() }
                
                guard let data = data, let image = UIImage(data: data) else { return }
                
                lock.lock()
                images[album.id] = image
                lock.unlock()
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }
    
    static func getAlbumCount(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall: return 1
        case .systemMedium: return 3
        case .systemLarge: return 6
        @unknown default: return 1
        }
    }
    
    static func resizeArtworkURL(_ urlString: String, size: Int = artworkSize) -> String {
        guard urlString.contains("mzstatic.com"),
              let range = urlString.range(of: "/\\d+x\\d+bb\\.jpg", options: .regularExpression) else {
            return urlString
        }
        return urlString.replacingCharacters(in: range, with: "/\(size)x\(size)bb.jpg")
    }
    
    static func resizeBackgroundImageForWidget(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let constrainedSize: CGSize
        if targetSize.width > maxImageDimension || targetSize.height > maxImageDimension {
            let aspectRatio = targetSize.width / targetSize.height
            if targetSize.width > targetSize.height {
                constrainedSize = CGSize(width: maxImageDimension, height: maxImageDimension / aspectRatio)
            } else {
                constrainedSize = CGSize(width: maxImageDimension * aspectRatio, height: maxImageDimension)
            }
        } else {
            constrainedSize = targetSize
        }
        
        if image.size.width <= constrainedSize.width && image.size.height <= constrainedSize.height {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(constrainedSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: constrainedSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    static func deepLinkURL(for album: ShortlistAlbum) -> URL? {
        var components = URLComponents()
        components.scheme = "shortlist"
        components.host = "album"
        
        var queryItems = [
            URLQueryItem(name: "title", value: album.title),
            URLQueryItem(name: "artist", value: album.artist),
            URLQueryItem(name: "id", value: album.id)
        ]
        
        if let appleAlbumURL = album.appleAlbumURL {
            queryItems.append(URLQueryItem(name: "appleAlbumURL", value: appleAlbumURL))
        }
        
        components.queryItems = queryItems
        return components.url
    }
    
    static func openAppURL() -> URL? {
        URL(string: "shortlist://open")
    }
}

