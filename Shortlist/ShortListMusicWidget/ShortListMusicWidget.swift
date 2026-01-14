//
//  ShortListMusicWidget.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import WidgetKit
import SwiftUI
import CloudKit
import UIKit

// MARK: - Widget Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage] // Cache of downloaded images keyed by album ID
}

// MARK: - Widget View

struct ShortListMusicWidgetEntryView: View {
    var entry: ShortListMusicWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(album: entry.albums.first, image: entry.albums.first != nil ? entry.albumImages[entry.albums.first!.id] : nil)
            case .systemMedium:
                MediumWidgetView(albums: entry.albums, albumImages: entry.albumImages)
            case .systemLarge:
                LargeWidgetView(albums: entry.albums, albumImages: entry.albumImages)
            default:
                SmallWidgetView(album: entry.albums.first, image: entry.albums.first != nil ? entry.albumImages[entry.albums.first!.id] : nil)
            }
        }
        .containerBackground(for: .widget) {
            GeometryReader { geometry in
                let widgetSize = geometry.size
                let resizedImage = WidgetDataHelper.resizeBackgroundImageForWidget(
                    UIImage(named: "Background") ?? UIImage(),
                    targetSize: widgetSize
                )
                Image(uiImage: resizedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}

// MARK: - Widget Size Views

struct SmallWidgetView: View {
    let album: ShortlistAlbum?
    let image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let album = album, let deepLinkURL = WidgetDataHelper.deepLinkURL(for: album) {
                    Link(destination: deepLinkURL) {
                        SmallWidgetContentView(album: album, image: image, geometry: geometry)
                    }
                } else {
                    SmallWidgetContentView(album: album, image: image, geometry: geometry)
                }
            }
        }
    }
}

struct SmallWidgetContentView: View {
    let album: ShortlistAlbum?
    let image: UIImage?
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            // Album artwork - square with rounded corners
            Group {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else if let album = album, !album.artworkURLString.isEmpty {
                            // Resize URL for widget-appropriate size and load
                            let resizedURL = WidgetDataHelper.resizeArtworkURL(album.artworkURLString, size: 200)
                            if let url = URL(string: resizedURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure, .empty:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .overlay(
                                                Image(systemName: "music.note")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.gray)
                                            )
                                    @unknown default:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                    )
                            }
                        } else {
                            // Placeholder if no image or album
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .frame(width: geometry.size.width * 0.6)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
                    .cornerRadius(6)
                    
                    // Album title and artist below artwork
                    VStack(alignment: .center, spacing: 2) {
                        if let album = album {
                            Text(album.title)
                                .font(Theme.shared.avenir(size: 13, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text(album.artist)
                                .font(Theme.shared.avenir(size: 11, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    
                    Spacer()
                }
                .overlay(alignment: .topTrailing) {
                    // Logo in top right corner - positioned as close to corner as possible
                    ShortListLogo(size: 30)
                        .padding(.top, -12) // Negative padding to push closer to top edge
                        .padding(.trailing, -12) // Negative padding to push closer to right edge
                }
    }
}

// MARK: - Reusable Album Cell View

struct AlbumCellView: View {
    let album: ShortlistAlbum
    let image: UIImage?
    let imageSize: CGFloat
    
    var body: some View {
        if let deepLinkURL = WidgetDataHelper.deepLinkURL(for: album) {
            Link(destination: deepLinkURL) {
                AlbumCellContentView(album: album, image: image, imageSize: imageSize)
            }
        } else {
            AlbumCellContentView(album: album, image: image, imageSize: imageSize)
        }
    }
}

struct AlbumCellContentView: View {
    let album: ShortlistAlbum
    let image: UIImage?
    let imageSize: CGFloat
    
    var body: some View {
        VStack(spacing: 6) {
            // Album artwork - square with rounded corners
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if !album.artworkURLString.isEmpty {
                    // Resize URL for widget-appropriate size and load
                    let resizedURL = WidgetDataHelper.resizeArtworkURL(album.artworkURLString, size: 200)
                    if let url = URL(string: resizedURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure, .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: imageSize * 0.3))
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: imageSize * 0.3))
                                    .foregroundColor(.gray)
                            )
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: imageSize * 0.3))
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: imageSize, height: imageSize)
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            .cornerRadius(6)
            
            // Album title and artist
            VStack(alignment: .center, spacing: 1) {
                Text(album.title)
                    .font(Theme.shared.avenir(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                
                Text(album.artist)
                    .font(Theme.shared.avenir(size: 11, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: imageSize)
            .padding(.horizontal, 2)
        }
    }
}

struct MediumWidgetView: View {
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage]
    
    private var displayAlbums: [ShortlistAlbum] {
        Array(albums.prefix(3))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 10) {
                    ForEach(displayAlbums) { album in
                        AlbumCellView(
                            album: album,
                            image: albumImages[album.id],
                            imageSize: min((geometry.size.width - 48) / 3, geometry.size.height * 0.65)
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .topTrailing) {
                // Logo in top right corner
                ShortListLogo(size: 30)
                    .padding(.top, -12)
                    .padding(.trailing, -12)
            }
        }
    }
}

struct LargeWidgetView: View {
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage]
    
    private var displayAlbums: [ShortlistAlbum] {
        Array(albums.prefix(6))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 12) {
                    // Top row - 3 albums
                    HStack(spacing: 10) {
                        ForEach(Array(displayAlbums.prefix(3))) { album in
                            AlbumCellView(
                                album: album,
                                image: albumImages[album.id],
                                imageSize: min((geometry.size.width - 48) / 3, (geometry.size.height - 40) / 2)
                            )
                        }
                    }
                    
                    // Bottom row - 3 albums
                    HStack(spacing: 10) {
                        ForEach(Array(displayAlbums.suffix(3))) { album in
                            AlbumCellView(
                                album: album,
                                image: albumImages[album.id],
                                imageSize: min((geometry.size.width - 48) / 3, (geometry.size.height - 40) / 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .topTrailing) {
                // Logo in top right corner
                ShortListLogo(size: 30)
                    .padding(.top, -12)
                    .padding(.trailing, -12)
            }
        }
    }
}

// MARK: - Widget Configuration

struct ShortListMusicWidget: Widget {
    let kind: String = "ShortListMusicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShortListMusicWidgetProvider()) { entry in
            ShortListMusicWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Shortlist Mix")
        .description("Shows random albums from your shortlists")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview Data

extension ShortlistAlbum {
    static let preview = ShortlistAlbum(
        id: "preview-1",
        title: "Sample Album",
        artist: "Sample Artist",
        artworkURLString: "https://via.placeholder.com/300x300",
        rank: 1,
        shortlistId: "preview-shortlist",
        upc: nil,
        appleAlbumURL: nil,
        recordID: CKRecord.ID(recordName: "preview-1")
    )
    
    static let previewAlbums: [ShortlistAlbum] = [
        ShortlistAlbum(id: "preview-1", title: "Abbey Road", artist: "The Beatles", artworkURLString: "https://via.placeholder.com/300x300", rank: 1, shortlistId: "preview-shortlist", upc: nil, appleAlbumURL: nil, recordID: CKRecord.ID(recordName: "preview-1")),
        ShortlistAlbum(id: "preview-2", title: "Dark Side of the Moon", artist: "Pink Floyd", artworkURLString: "https://via.placeholder.com/300x300", rank: 2, shortlistId: "preview-shortlist", upc: nil, appleAlbumURL: nil, recordID: CKRecord.ID(recordName: "preview-2")),
        ShortlistAlbum(id: "preview-3", title: "Rumours", artist: "Fleetwood Mac", artworkURLString: "https://via.placeholder.com/300x300", rank: 3, shortlistId: "preview-shortlist", upc: nil, appleAlbumURL: nil, recordID: CKRecord.ID(recordName: "preview-3")),
        ShortlistAlbum(id: "preview-4", title: "Hotel California", artist: "Eagles", artworkURLString: "https://via.placeholder.com/300x300", rank: 4, shortlistId: "preview-shortlist", upc: nil, appleAlbumURL: nil, recordID: CKRecord.ID(recordName: "preview-4")),
        ShortlistAlbum(id: "preview-5", title: "The Wall", artist: "Pink Floyd", artworkURLString: "https://via.placeholder.com/300x300", rank: 5, shortlistId: "preview-shortlist", upc: nil, appleAlbumURL: nil, recordID: CKRecord.ID(recordName: "preview-5")),
        ShortlistAlbum(id: "preview-6", title: "Led Zeppelin IV", artist: "Led Zeppelin", artworkURLString: "https://via.placeholder.com/300x300", rank: 6, shortlistId: "preview-shortlist", upc: nil, appleAlbumURL: nil, recordID: CKRecord.ID(recordName: "preview-6"))
    ]
}

extension SimpleEntry {
    static let smallPreview = SimpleEntry(date: .now, albums: [ShortlistAlbum.preview], albumImages: [:])
    static let mediumPreview = SimpleEntry(date: .now, albums: Array(ShortlistAlbum.previewAlbums.prefix(3)), albumImages: [:])
    static let largePreview = SimpleEntry(date: .now, albums: Array(ShortlistAlbum.previewAlbums.prefix(6)), albumImages: [:])
}

#Preview("Small Widget", as: .systemSmall) {
    ShortListMusicWidget()
} timeline: {
    SimpleEntry.smallPreview
}

#Preview("Medium Widget", as: .systemMedium) {
    ShortListMusicWidget()
} timeline: {
    SimpleEntry.mediumPreview
}

#Preview("Large Widget", as: .systemLarge) {
    ShortListMusicWidget()
} timeline: {
    SimpleEntry.largePreview
}
