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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let albums: [ShortlistAlbum]
    let albumImages: [String: UIImage]
}

struct ShortListMusicWidgetEntryView: View {
    var entry: ShortListMusicWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if entry.albums.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .containerBackground(for: .widget) {
            backgroundView
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        switch family {
        case .systemSmall: EmptySmallWidgetView()
        case .systemMedium: EmptyMediumWidgetView()
        case .systemLarge: EmptyLargeWidgetView()
        default: EmptySmallWidgetView()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(
                album: entry.albums.first,
                image: entry.albums.first.flatMap { entry.albumImages[$0.id] }
            )
        case .systemMedium:
            MediumWidgetView(albums: entry.albums, albumImages: entry.albumImages)
        case .systemLarge:
            LargeWidgetView(albums: entry.albums, albumImages: entry.albumImages)
        default:
            SmallWidgetView(
                album: entry.albums.first,
                image: entry.albums.first.flatMap { entry.albumImages[$0.id] }
            )
        }
    }
    
    private var backgroundView: some View {
        GeometryReader { geometry in
            let widgetSize = geometry.size
            let resizedImage = WidgetDataHelper.resizeBackgroundImageForWidget(
                UIImage(named: "Background") ?? UIImage(),
                targetSize: widgetSize
            )
            let logoSize = min(widgetSize.width, widgetSize.height) * 0.95
            
            ZStack {
                Image(uiImage: resizedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: widgetSize.width, height: widgetSize.height)
                
                if let logoImage = UIImage(named: "BackgroundLogo") {
                    Image(uiImage: WidgetDataHelper.resizeBackgroundImageForWidget(logoImage, targetSize: CGSize(width: logoSize, height: logoSize)))
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .opacity(0.3)
                } else {
                    Image("BackgroundLogo")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .opacity(0.3)
                }
            }
            .frame(width: widgetSize.width, height: widgetSize.height)
        }
    }
}

struct EmptySmallWidgetView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 12) {
                    Spacer()
                    
                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 4) {
                        Text("No Shortlists")
                            .font(Theme.shared.avenir(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Tap to create one")
                            .font(Theme.shared.avenir(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .widgetURL(WidgetDataHelper.openAppURL())
    }
}

struct EmptyMediumWidgetView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 12) {
                    Spacer()
                    
                    Image(systemName: "music.note.list")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 4) {
                        Text("No Shortlists Yet")
                            .font(Theme.shared.avenir(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Create a shortlist to see albums here")
                            .font(Theme.shared.avenir(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .widgetURL(WidgetDataHelper.openAppURL())
    }
}

struct EmptyLargeWidgetView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 6) {
                        Text("No Shortlists Yet")
                            .font(Theme.shared.avenir(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Create a shortlist and add albums to see them here")
                            .font(Theme.shared.avenir(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .widgetURL(WidgetDataHelper.openAppURL())
    }
}

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
            
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let album = album, !album.artworkURLString.isEmpty {
                    let resizedURL = WidgetDataHelper.resizeArtworkURL(album.artworkURLString, size: 400)
                    if let url = URL(string: resizedURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure, .empty:
                                placeholderImage(size: 30)
                            @unknown default:
                                Rectangle().fill(Color.gray.opacity(0.3))
                            }
                        }
                    } else {
                        placeholderImage(size: 30)
                    }
                } else {
                    placeholderImage(size: 30)
                }
            }
            .frame(width: geometry.size.width * 0.6)
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            .cornerRadius(6)
            
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
    }
    
    @ViewBuilder
    private func placeholderImage(size: CGFloat) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: size))
                    .foregroundColor(.gray)
            )
    }
}

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
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if !album.artworkURLString.isEmpty {
                    let resizedURL = WidgetDataHelper.resizeArtworkURL(album.artworkURLString, size: 400)
                    if let url = URL(string: resizedURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure, .empty:
                                placeholderImage
                            @unknown default:
                                Rectangle().fill(Color.gray.opacity(0.3))
                            }
                        }
                    } else {
                        placeholderImage
                    }
                } else {
                    placeholderImage
                }
            }
            .frame(width: imageSize, height: imageSize)
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            .cornerRadius(6)
            
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
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: imageSize * 0.3))
                    .foregroundColor(.gray)
            )
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
                            imageSize: min((geometry.size.width - 48) / CGFloat(max(displayAlbums.count, 1)), geometry.size.height * 0.65)
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .widgetURL(WidgetDataHelper.openAppURL())
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
            let imageSize = min((geometry.size.width - 48) / 3, (geometry.size.height - 40) / 2)
            
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ForEach(Array(displayAlbums.prefix(3))) { album in
                        AlbumCellView(album: album, image: albumImages[album.id], imageSize: imageSize)
                    }
                }
                
                if displayAlbums.count > 3 {
                    HStack(spacing: 10) {
                        ForEach(Array(displayAlbums.suffix(displayAlbums.count - 3))) { album in
                            AlbumCellView(album: album, image: albumImages[album.id], imageSize: imageSize)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .widgetURL(WidgetDataHelper.openAppURL())
    }
}

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
