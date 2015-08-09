//
//  SpotifyAlbum.h
//  shortList
//
//  Created by Dustin Bergman on 8/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface SpotifyAlbum : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *spotifyAlbumUrl;

@end
