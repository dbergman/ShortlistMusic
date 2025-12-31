# Widget Data Helper Methods

This document outlines the helper methods available for retrieving and processing data in the ShortListMusicWidget.

## Location
All helper methods are located in `WidgetDataHelper.swift`

## Main Data Retrieval Methods

### `fetchAlbums(for:completion:)`
Fetches albums from CloudKit for a specific widget family.

**Parameters:**
- `family: WidgetFamily` - The widget family (small, medium, large)
- `completion: @escaping ([ShortlistAlbum]) -> Void` - Completion handler with fetched albums

**Usage:**
```swift
WidgetDataHelper.fetchAlbums(for: .systemMedium) { albums in
    // Use albums here
}
```

**What it does:**
1. Calls `WidgetCloudKitManager.shared.getAllAlbums()` to fetch all albums from CloudKit
2. Determines the required album count based on widget family
3. Shuffles the albums and selects the required number
4. Returns the selected albums via completion handler

---

### `preloadImages(for:completion:)`
Preloads and resizes album artwork images for widget display.

**Parameters:**
- `albums: [ShortlistAlbum]` - Array of albums to preload images for
- `completion: @escaping ([String: UIImage]) -> Void` - Completion handler with dictionary of album ID to UIImage

**Usage:**
```swift
WidgetDataHelper.preloadImages(for: albums) { images in
    // images dictionary: [albumId: UIImage]
}
```

**What it does:**
1. Downloads artwork images from URLs in parallel
2. Resizes images to widget-appropriate size (max 300px)
3. Returns a dictionary mapping album IDs to UIImage instances
4. Handles errors gracefully (skips invalid URLs, continues on download failures)

---

## Utility Methods

### `getAlbumCount(for:)`
Returns the number of albums to display for a given widget family.

**Parameters:**
- `family: WidgetFamily` - The widget family

**Returns:**
- `Int` - Number of albums to display

**Album counts:**
- `.systemSmall`: 1 album
- `.systemMedium`: 3 albums
- `.systemLarge`: 6 albums

**Usage:**
```swift
let count = WidgetDataHelper.getAlbumCount(for: .systemMedium) // Returns 3
```

---

### `resizeImageForWidget(_:maxDimension:)`
Resizes an image to widget-appropriate size.

**Parameters:**
- `image: UIImage` - The image to resize
- `maxDimension: CGFloat` - Maximum dimension (default 300px for album artwork)

**Returns:**
- `UIImage` - Resized image

**What it does:**
- Maintains aspect ratio
- Constrains to maximum dimension
- Returns original image if already smaller than max dimension

**Usage:**
```swift
let resized = WidgetDataHelper.resizeImageForWidget(originalImage, maxDimension: 300)
```

---

### `resizeBackgroundImageForWidget(_:targetSize:)`
Resizes background image to widget size.

**Parameters:**
- `image: UIImage` - The background image
- `targetSize: CGSize` - Target size for the widget

**Returns:**
- `UIImage` - Resized image

**Usage:**
```swift
let resized = WidgetDataHelper.resizeBackgroundImageForWidget(bgImage, targetSize: widgetSize)
```

---

## Underlying Data Source

### `WidgetCloudKitManager.shared.getAllAlbums(completion:)`
The underlying CloudKit manager that fetches albums from the user's shortlists.

**Location:** `WidgetCloudKitManager.swift`

**What it does:**
1. Fetches the current user's record ID
2. Queries CloudKit for all shortlists created by the user
3. Fetches all albums from those shortlists
4. Returns all albums as `[ShortlistAlbum]`

**Note:** This is a standalone CloudKit manager for widgets that doesn't require MusicKit dependencies.

---

## Example: Complete Data Fetch Flow

```swift
// 1. Fetch albums for medium widget
WidgetDataHelper.fetchAlbums(for: .systemMedium) { albums in
    guard !albums.isEmpty else {
        // Handle empty state
        return
    }
    
    // 2. Preload images
    WidgetDataHelper.preloadImages(for: albums) { images in
        // 3. Create widget entry with albums and images
        let entry = SimpleEntry(
            date: Date(),
            albums: albums,
            albumImages: images
        )
        
        // Use entry to render widget
    }
}
```

