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
        Text("Hello, World!")
    }
}

struct MediumWidgetView: View {
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage]
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct LargeWidgetView: View {
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage]
    
    private var displayAlbums: [ShortlistAlbum] {
        Array(albums.prefix(6))
    }
    
    var body: some View {
        Text("Hello, World!")
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
        recordID: CKRecord.ID(recordName: "preview-1")
    )
    
    static let previewAlbums: [ShortlistAlbum] = [
        ShortlistAlbum(id: "preview-1", title: "Abbey Road", artist: "The Beatles", artworkURLString: "https://via.placeholder.com/300x300", rank: 1, shortlistId: "preview-shortlist", upc: nil, recordID: CKRecord.ID(recordName: "preview-1")),
        ShortlistAlbum(id: "preview-2", title: "Dark Side of the Moon", artist: "Pink Floyd", artworkURLString: "https://via.placeholder.com/300x300", rank: 2, shortlistId: "preview-shortlist", upc: nil, recordID: CKRecord.ID(recordName: "preview-2")),
        ShortlistAlbum(id: "preview-3", title: "Rumours", artist: "Fleetwood Mac", artworkURLString: "https://via.placeholder.com/300x300", rank: 3, shortlistId: "preview-shortlist", upc: nil, recordID: CKRecord.ID(recordName: "preview-3")),
        ShortlistAlbum(id: "preview-4", title: "Hotel California", artist: "Eagles", artworkURLString: "https://via.placeholder.com/300x300", rank: 4, shortlistId: "preview-shortlist", upc: nil, recordID: CKRecord.ID(recordName: "preview-4")),
        ShortlistAlbum(id: "preview-5", title: "The Wall", artist: "Pink Floyd", artworkURLString: "https://via.placeholder.com/300x300", rank: 5, shortlistId: "preview-shortlist", upc: nil, recordID: CKRecord.ID(recordName: "preview-5")),
        ShortlistAlbum(id: "preview-6", title: "Led Zeppelin IV", artist: "Led Zeppelin", artworkURLString: "https://via.placeholder.com/300x300", rank: 6, shortlistId: "preview-shortlist", upc: nil, recordID: CKRecord.ID(recordName: "preview-6"))
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
