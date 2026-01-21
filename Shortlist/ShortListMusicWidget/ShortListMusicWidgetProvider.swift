//
//  ShortListMusicWidgetProvider.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import WidgetKit
import CloudKit
import os

struct ShortListMusicWidgetProvider: TimelineProvider {
    private static let updateInterval: TimeInterval = 3600
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), albums: [], albumImages: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        if context.isPreview {
            let count = WidgetDataHelper.getAlbumCount(for: context.family)
            let albums = Array(ShortlistAlbum.previewAlbums.prefix(count))
            completion(SimpleEntry(date: Date(), albums: albums, albumImages: [:]))
            return
        }
        
        WidgetDataHelper.fetchAlbums(for: context.family) { albums in
            completion(SimpleEntry(date: Date(), albums: albums, albumImages: [:]))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let currentDate = Date()
        
        if context.isPreview {
            let count = WidgetDataHelper.getAlbumCount(for: context.family)
            let albums = Array(ShortlistAlbum.previewAlbums.prefix(count))
            let entry = SimpleEntry(date: currentDate, albums: albums, albumImages: [:])
            completion(Timeline(entries: [entry], policy: .never))
            return
        }
        
        WidgetDataHelper.fetchAlbums(for: context.family) { albums in
            guard !albums.isEmpty else {
                let entry = SimpleEntry(date: currentDate, albums: [], albumImages: [:])
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(Self.updateInterval)
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
                return
            }
            
            WidgetDataHelper.preloadImages(for: albums) { images in
                let entry = SimpleEntry(date: currentDate, albums: albums, albumImages: images)
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(Self.updateInterval)
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            }
        }
    }
}

