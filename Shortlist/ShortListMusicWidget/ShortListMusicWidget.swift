//
//  ShortListMusicWidget.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import os
import WidgetKit
import SwiftUI
import CloudKit
import UIKit

let logger = Logger(subsystem: "com.dus.shortList.dev.ShortListMusicWidgetExtension", category: "Widget")

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        // Use empty arrays - the view will show redacted placeholders
        return SimpleEntry(date: Date(), albums: [], albumImages: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        logger.debug("Widget: getSnapshot called for family: \(context.family)")
        
        // For snapshots (widget gallery preview), try to get real data quickly
        // If it's not available, return empty arrays for redacted placeholders
        fetchAlbums(for: context.family) { albums in
            let entry: SimpleEntry
            if albums.isEmpty {
                // Return empty for redacted placeholder
                entry = SimpleEntry(date: Date(), albums: [], albumImages: [:])
            } else {
                let albumCount = getAlbumCount(for: context.family)
                let shuffledAlbums = albums.shuffled()
                let selectedAlbums = Array(shuffledAlbums.prefix(albumCount))
                entry = SimpleEntry(date: Date(), albums: selectedAlbums, albumImages: [:])
            }
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        
        logger.debug("Widget: Timeline called for family: \(context.family)")
        logger.debug("Widget: Context isPreview: \(context.isPreview)")
        
        // Try to fetch real albums from CloudKit first
        fetchAlbums(for: context.family) { albums in
            let finalAlbums: [ShortlistAlbum]
            
            if albums.isEmpty {
                logger.debug("Widget: No real albums found, showing empty state")
                finalAlbums = []
            } else {
                logger.debug("Widget: Using \(albums.count) real albums")
                finalAlbums = albums
            }
            
            // If no albums, create entry immediately without image preloading
            guard !finalAlbums.isEmpty else {
                let entry = SimpleEntry(date: currentDate, albums: [], albumImages: [:])
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                logger.debug("Widget: Timeline created with empty albums, next update: \(nextUpdate)")
                completion(timeline)
                return
            }
            
            // Preload images for albums before creating entry
            preloadImages(for: finalAlbums) { images in
                    // Create entry with albums and preloaded images
                    let entry = SimpleEntry(date: currentDate, albums: finalAlbums, albumImages: images)
                    
                    // Update every 30 minutes - fallback to 30 minutes from now if date calculation fails
                    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
                
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                logger.debug("Widget: Timeline created with \(finalAlbums.count) albums, \(images.count) images, next update: \(nextUpdate)")
                completion(timeline)
            }
        }
    }
    
    private func preloadImages(for albums: [ShortlistAlbum], completion: @escaping ([String: UIImage]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var images: [String: UIImage] = [:]
        let lock = NSLock()
        
        logger.debug("Widget: Preloading images for \(albums.count) albums")
        
        for album in albums {
            guard !album.artworkURLString.isEmpty,
                  let url = URL(string: album.artworkURLString),
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
                
                lock.lock()
                images[album.id] = image
                lock.unlock()
                logger.debug("Widget: Successfully loaded image for \(album.title)")
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            logger.debug("Widget: Finished preloading images. Got \(images.count) images out of \(albums.count) albums")
            completion(images)
        }
    }
    
    private func fetchAlbums(for family: WidgetFamily, completion: @escaping ([ShortlistAlbum]) -> Void) {
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

                // Shuffle and take random albums
                let shuffledAlbums = allAlbums.shuffled()
                let selectedAlbums = Array(shuffledAlbums.prefix(albumCount))

                logger.debug("Widget: Selected \(selectedAlbums.count) albums for \(family) widget")
                logger.debug("Widget: Selected albums: \(selectedAlbums.map { "\($0.title) by \($0.artist)" })")
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
    
    private func createSampleAlbums(count: Int) -> [ShortlistAlbum] {
        logger.debug("Widget: Creating \(count) sample albums")
        
        let sampleTitles = [
            "Midnight City", "Electric Dreams", "Neon Nights", "Digital Love",
            "Cosmic Waves", "Future Memories", "Urban Legends", "Stellar Vibes"
        ]
        
        let sampleArtists = [
            "The Synthesizers", "Digital Echo", "Neon Pulse", "Cosmic Sound",
            "Future Beats", "Urban Rhythm", "Stellar Wave", "Electric Soul"
        ]
        
        // Use reliable album artwork URLs
        let sampleArtworkURLs = [
            "https://picsum.photos/300/300?random=1",
            "https://picsum.photos/300/300?random=2", 
            "https://picsum.photos/300/300?random=3",
            "https://picsum.photos/300/300?random=4",
            "https://picsum.photos/300/300?random=5",
            "https://picsum.photos/300/300?random=6",
            "https://picsum.photos/300/300?random=7",
            "https://picsum.photos/300/300?random=8"
        ]
        
        let albums = (0..<count).map { index in
            let album = ShortlistAlbum(
                id: "sample-\(index)",
                title: sampleTitles[index % sampleTitles.count],
                artist: sampleArtists[index % sampleArtists.count],
                artworkURLString: sampleArtworkURLs[index % sampleArtworkURLs.count],
                rank: index + 1,
                shortlistId: "sample-shortlist",
                upc: nil,
                recordID: CKRecord.ID(recordName: "sample-\(index)")
            )
            logger.debug("Widget: Created album: \(album.title) by \(album.artist) with artwork: \(album.artworkURLString)")
            return album
        }
        
        logger.debug("Widget: Successfully created \(albums.count) sample albums")
        return albums
    }
}

private func getAlbumCount(for family: WidgetFamily) -> Int {
    switch family {
    case .systemSmall:
        return 1
    case .systemMedium:
        return 3  // Reduced from 4 to 3 to prevent cutoff
    case .systemLarge:
        return 6  // Reduced from 8 to 6 to prevent cutoff
    default:
        return 1
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage] // Cache of downloaded images keyed by album ID
}

struct ShortListMusicWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if entry.albums.isEmpty {
                // Show redacted placeholder when no albums
                redactedPlaceholderView
            } else {
                switch family {
                case .systemSmall:
                    if let firstAlbum = entry.albums.first {
                        SmallAlbumView(album: firstAlbum, image: entry.albumImages[firstAlbum.id])
                    } else {
                        redactedPlaceholderView
                    }
                case .systemMedium:
                    MediumAlbumsView(albums: entry.albums, albumImages: entry.albumImages)
                case .systemLarge:
                    LargeAlbumsView(albums: entry.albums, albumImages: entry.albumImages)
                default:
                    if let firstAlbum = entry.albums.first {
                        SmallAlbumView(album: firstAlbum, image: entry.albumImages[firstAlbum.id])
                    } else {
                        redactedPlaceholderView
                    }
                }
            }
        }
        .onAppear {
            logger.debug("Widget View: Albums count: \(entry.albums.count), Family: \(family)")
            if entry.albums.isEmpty {
                logger.debug("Widget View: Showing redacted placeholder")
            } else {
                logger.debug("Widget View: Showing albums for family: \(family)")
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    @ViewBuilder
    private var redactedPlaceholderView: some View {
        switch family {
        case .systemSmall:
            SmallAlbumPlaceholder()
                .redacted(reason: .placeholder)
        case .systemMedium:
            MediumAlbumsPlaceholder()
                .redacted(reason: .placeholder)
        case .systemLarge:
            LargeAlbumsPlaceholder()
                .redacted(reason: .placeholder)
        default:
            SmallAlbumPlaceholder()
                .redacted(reason: .placeholder)
        }
    }
}

struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            MusicIconView()
                .frame(width: 32, height: 32)
            
            Text("No Albums")
                .font(Theme.shared.avenir(size: 17, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// Placeholder views that match the structure of actual views
struct SmallAlbumPlaceholder: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width
            let maxHeight = geometry.size.height
            let availableHeight = maxHeight - 45
            let imageSize = min(maxWidth - 16, availableHeight, 125)
            
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2))
                    .frame(width: imageSize, height: imageSize)
                    .shadow(
                        color: colorScheme == .dark ? 
                            Color.black.opacity(0.6) : 
                            Color.black.opacity(0.15),
                        radius: colorScheme == .dark ? 16 : 10,
                        x: 0,
                        y: colorScheme == .dark ? 8 : 5
                    )
            
                VStack(spacing: 2) {
                    Text("Album Title")
                        .font(Theme.shared.avenir(size: 9, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Artist Name")
                        .font(Theme.shared.avenir(size: 8, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
        }
    }
}

struct MediumAlbumsPlaceholder: View {
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 24
            let availableHeight = geometry.size.height - 40
            let itemWidth = (availableWidth - 16) / 3
            let imageSize = min(itemWidth - 2, availableHeight - 32)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    MusicIconView()
                        .frame(width: 14, height: 14)
                    Text("My Albums")
                        .font(Theme.shared.avenir(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        AlbumGridItemPlaceholder(imageSize: imageSize)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct LargeAlbumsPlaceholder: View {
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 32
            let availableHeight = geometry.size.height - 45
            let itemWidth = (availableWidth - 8) / 2
            let itemHeight = (availableHeight - 10) / 3
            let imageSize = min(itemWidth - 2, itemHeight - 32)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    MusicIconView()
                        .frame(width: 16, height: 16)
                    Text("My Albums")
                        .font(Theme.shared.avenir(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 10) {
                    ForEach(0..<6, id: \.self) { _ in
                        AlbumGridItemPlaceholder(imageSize: imageSize)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct AlbumGridItemPlaceholder: View {
    @Environment(\.colorScheme) var colorScheme
    var imageSize: CGFloat = 90
    
    var body: some View {
        VStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2))
                .frame(width: imageSize, height: imageSize)
                .shadow(
                    color: colorScheme == .dark ? 
                        Color.black.opacity(0.6) : 
                        Color.black.opacity(0.15),
                    radius: colorScheme == .dark ? 16 : 10,
                    x: 0,
                    y: colorScheme == .dark ? 8 : 5
                )
            
            VStack(spacing: 1) {
                Text("Album")
                    .font(Theme.shared.avenir(size: 8, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Artist")
                    .font(Theme.shared.avenir(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SmallAlbumView: View {
    let album: ShortlistAlbum
    let image: UIImage?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width
            let maxHeight = geometry.size.height
            let availableHeight = maxHeight - 45 // Reduced space for smaller text
            let imageSize = min(maxWidth - 16, availableHeight, 125) // Increased from 105 to 125
            
            VStack(spacing: 4) {
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2))
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(colorScheme == .dark ? Color.blue.opacity(0.8) : .blue)
                            )
                    }
                }
                .frame(width: imageSize, height: imageSize)
                .clipped()
                .cornerRadius(12)
                .shadow(
                    color: colorScheme == .dark ? 
                        Color.black.opacity(0.6) : 
                        Color.black.opacity(0.15),
                    radius: colorScheme == .dark ? 16 : 10,
                    x: 0,
                    y: colorScheme == .dark ? 8 : 5
                )
                
                VStack(spacing: 2) {
                    Text(album.title)
                        .font(Theme.shared.avenir(size: 9, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                    
                    Text(album.artist)
                        .font(Theme.shared.avenir(size: 8, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
        }
    }
}

struct MediumAlbumsView: View {
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage]
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 24 // Padding
            let availableHeight = geometry.size.height - 40 // Header + padding
            let itemWidth = (availableWidth - 16) / 3 // 3 items with spacing
            let imageSize = min(itemWidth - 2, availableHeight - 32) // Increased size, reduced text space
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    MusicIconView()
                        .frame(width: 14, height: 14)
                    Text("My Albums")
                        .font(Theme.shared.avenir(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    ForEach(albums.prefix(3)) { album in
                        AlbumGridItem(album: album, image: albumImages[album.id], imageSize: imageSize)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct LargeAlbumsView: View {
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage]
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 32 // Padding
            let availableHeight = geometry.size.height - 45 // Header + padding
            let itemWidth = (availableWidth - 8) / 2 // 2 columns with spacing
            let itemHeight = (availableHeight - 10) / 3 // 3 rows with spacing
            let imageSize = min(itemWidth - 2, itemHeight - 32) // Increased size, reduced text space
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    MusicIconView()
                        .frame(width: 16, height: 16)
                    Text("My Albums")
                        .font(Theme.shared.avenir(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 10) {
                    ForEach(albums.prefix(6)) { album in
                        AlbumGridItem(album: album, image: albumImages[album.id], imageSize: imageSize)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct AlbumGridItem: View {
    let album: ShortlistAlbum
    let image: UIImage?
    var imageSize: CGFloat = 90
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 3) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2))
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(colorScheme == .dark ? Color.blue.opacity(0.8) : .blue)
                        )
                }
            }
            .frame(width: imageSize, height: imageSize)
            .clipped()
            .cornerRadius(10)
            .shadow(
                color: colorScheme == .dark ? 
                    Color.black.opacity(0.6) : 
                    Color.black.opacity(0.15),
                radius: colorScheme == .dark ? 16 : 10,
                x: 0,
                y: colorScheme == .dark ? 8 : 5
            )
            
            VStack(spacing: 1) {
                Text(album.title)
                    .font(Theme.shared.avenir(size: 8, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                
                Text(album.artist)
                    .font(Theme.shared.avenir(size: 7, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MusicIconView: View {
    var body: some View {
        ZStack {
            // Use system images temporarily to avoid asset catalog issues
            Image(systemName: "circle.fill")
                .foregroundColor(.gray)
                .font(Theme.shared.avenir(size: 24, weight: .regular))
            
            Image(systemName: "music.note")
                .foregroundColor(.blue)
                .font(Theme.shared.avenir(size: 12, weight: .regular))
        }
    }
}

struct ShortListMusicWidget: Widget {
    let kind: String = "ShortListMusicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ShortListMusicWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Albums")
        .description("Shows random albums from your shortlists")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

// Preview data
extension ShortlistAlbum {
    static let preview = ShortlistAlbum(
        id: "preview-1",
        title: "Sample Album",
        artist: "Sample Artist",
        artworkURLString: "https://via.placeholder.com/300x300",
        rank: 1,
        shortlistId: "preview-shortlist",
        upc: nil,
        recordID: CKRecord.ID(recordName: "preview-1")
    )
}

#Preview(as: .systemSmall) {
    ShortListMusicWidget()
} timeline: {
    SimpleEntry(date: .now, albums: [ShortlistAlbum.preview], albumImages: [:])
    SimpleEntry(date: .now, albums: [], albumImages: [:])
}

#Preview(as: .systemMedium) {
    ShortListMusicWidget()
} timeline: {
    SimpleEntry(date: .now, albums: Array(repeating: ShortlistAlbum.preview, count: 3), albumImages: [:])
}

#Preview(as: .systemLarge) {
    ShortListMusicWidget()
} timeline: {
    SimpleEntry(date: .now, albums: Array(repeating: ShortlistAlbum.preview, count: 6), albumImages: [:])
}
