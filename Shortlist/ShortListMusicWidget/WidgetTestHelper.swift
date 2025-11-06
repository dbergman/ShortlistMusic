//
//  WidgetTestHelper.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/5/25.
//

import Foundation

#if DEBUG
class WidgetTestHelper {
    static func testCloudKitConnection() {
        WidgetCloudKitManager.shared.getAllAlbums { result in
            switch result {
            case .success(let albums):
                print("✅ Widget CloudKit Test: Successfully fetched \(albums.count) albums")
                for album in albums.prefix(3) {
                    print("  - \(album.title) by \(album.artist)")
                }
            case .failure(let error):
                print("❌ Widget CloudKit Test: Failed with error: \(error.localizedDescription)")
            }
        }
    }
}
#endif

