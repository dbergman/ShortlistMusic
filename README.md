# ShortlistMusic

A modern iOS app for creating and managing music shortlists using Apple's MusicKit and CloudKit. Build curated collections of your favorite albums, organize them by year, and share your musical discoveries.

## Features

- 🎵 **MusicKit Integration**: Search and discover music using Apple's MusicKit framework
- ☁️ **CloudKit Sync**: Your shortlists sync across all your devices using iCloud
- 📱 **Modern SwiftUI Interface**: Beautiful, responsive design with dark mode support
- 🔍 **Advanced Search**: Search by artist to discover albums and add them to your shortlists
- 📊 **Visual Grid Layout**: See your shortlists as beautiful album artwork grids
- 📧 **Sharing**: Export your shortlists via email or copy to clipboard
- 🎨 **Customizable Ordering**: Sort shortlists by year or creation date
- ⚡ **Real-time Updates**: Changes sync instantly across devices

## Dependencies

This project uses **Swift Package Manager (SPM)** for dependency management. The following packages are included:

### Swift Package Manager Dependencies
- **SkeletonUI** (2.0.2) - Loading skeleton animations
- **swift-custom-dump** (1.3.3) - Enhanced debugging output
- **swift-snapshot-testing** (1.18.5) - Snapshot testing framework
- **swift-syntax** (601.0.1) - Swift syntax parsing
- **xctest-dynamic-overlay** (1.6.0) - Dynamic test utilities

### Apple Frameworks
- **MusicKit** - Music discovery and search
- **CloudKit** - iCloud data synchronization
- **SwiftUI** - Modern UI framework
- **Foundation** - Core system services

## Prerequisites

- **Xcode 15.0+** (for iOS 17.0+ support)
- **iOS 17.0+** target device or simulator
- **Apple Developer Account** (for MusicKit and CloudKit capabilities)
- **iCloud Account** (for data synchronization)

## Setup & Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/ShortlistMusic.git
cd ShortlistMusic
```

### 2. Open in Xcode
```bash
open Shortlist/Shortlist.xcodeproj
```

### 3. Configure Capabilities
The app requires the following capabilities to be enabled in your Apple Developer account:

#### MusicKit
- Add `NSAppleMusicUsageDescription` to Info.plist
- Request music authorization in your app

#### CloudKit
- Enable CloudKit capability in Xcode
- Configure CloudKit container: `iCloud.com.dus.shortList`
- Set up CloudKit schema with the following record types:
  - `Shortlists` (name, year, id, createdTimestamp)
  - `Albums` (title, artist, artwork, rank, shortlistId, upc)

### 4. Build and Run
1. Select your target device or simulator
2. Press `Cmd + R` to build and run
3. Grant necessary permissions when prompted

## Development

### Project Structure
```
Shortlist/
├── CloudKit Manager/          # CloudKit data management
├── Helpers/                   # Utility classes and extensions
├── Models/                    # Data models (Shortlist, ShortlistAlbum)
├── Sections/                  # Main app sections
│   ├── Album Details/         # Album detail views
│   ├── Collections/           # Shortlist management
│   └── Search/                # Music search functionality
├── Theme/                     # App theming
└── MusicPermission/           # Music authorization handling
```

### Key Components

#### CloudKit Integration
- **CloudKitManager**: Handles all CloudKit operations
- **Record Types**: Shortlists and Albums with proper relationships
- **Sync Strategy**: Real-time synchronization across devices
- **Error Handling**: Comprehensive error management

#### MusicKit Integration
- **Search**: Artist and album discovery
- **Authorization**: Proper music library access
- **Data Models**: Integration with Apple Music catalog

#### UI Architecture
- **SwiftUI**: Modern declarative UI
- **MVVM Pattern**: Clean separation of concerns
- **Custom Components**: Reusable UI elements
- **Accessibility**: Full VoiceOver support

### Building for Different Environments

#### Debug
- Standard development build
- Uses development CloudKit container
- Includes debug logging

#### Release
- Production build for App Store
- Uses production CloudKit container
- Optimized performance

## CloudKit Schema

### Shortlists Record Type
- `id` (String): Unique identifier
- `name` (String): Shortlist name
- `year` (String): Year of the shortlist
- `createdTimestamp` (Date): Creation date

### Albums Record Type
- `id` (String): Album identifier
- `title` (String): Album title
- `artist` (String): Artist name
- `artwork` (String): Artwork URL
- `rank` (Int): Position in shortlist
- `shortlistId` (String): Reference to parent shortlist
- `upc` (String): Universal Product Code

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Apple MusicKit for music discovery
- Apple CloudKit for data synchronization
- SkeletonUI for loading animations
- Point-Free for testing utilities
