//
//  ShortListMusicWidgetProvider.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import WidgetKit
import CloudKit
import os

// MARK: - Timeline Provider

struct ShortListMusicWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), albums: [], albumImages: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        logger.debug("Widget: getSnapshot called for family: \(context.family), isPreview: \(context.isPreview)")
        
        // For previews, return sample data immediately
        if context.isPreview {
            let expectedCount = WidgetDataHelper.getAlbumCount(for: context.family)
            let previewAlbums = Array(ShortlistAlbum.previewAlbums.prefix(expectedCount))
            completion(SimpleEntry(date: Date(), albums: previewAlbums, albumImages: [:]))
            return
        }
        
        // For snapshots, try to get real data quickly
        WidgetDataHelper.fetchAlbums(for: context.family) { albums in
            let entry = SimpleEntry(date: Date(), albums: albums, albumImages: [:])
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        
        logger.debug("Widget: Timeline called for family: \(context.family)")
        
        // For previews, return sample data immediately
        if context.isPreview {
            let expectedCount = WidgetDataHelper.getAlbumCount(for: context.family)
            let previewAlbums = Array(ShortlistAlbum.previewAlbums.prefix(expectedCount))
            let entry = SimpleEntry(date: currentDate, albums: previewAlbums, albumImages: [:])
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
            return
        }
        
        // Fetch real albums from CloudKit
        WidgetDataHelper.fetchAlbums(for: context.family) { albums in
            guard !albums.isEmpty else {
                let entry = SimpleEntry(date: currentDate, albums: [], albumImages: [:])
                // Update every hour
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(3600)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
                return
            }
            
            // TEMPORARILY DISABLED: Image preloading to test if UIImage storage is causing archival issues
            // Preload images before creating entry
            // WidgetDataHelper.preloadImages(for: albums) { images in
            //     let entry = SimpleEntry(date: currentDate, albums: albums, albumImages: images)
            //     // Update every hour
            //     let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(3600)
            //     let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            //     completion(timeline)
            // }
            
            // Create entry without images
            let entry = SimpleEntry(date: currentDate, albums: albums, albumImages: [:])
            // Update every hour
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(3600)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

