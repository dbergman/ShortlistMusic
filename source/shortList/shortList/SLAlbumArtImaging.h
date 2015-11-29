//
//  SLAlbumArtImaging.h
//  shortList
//
//  Created by Dustin Bergman on 8/18/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class SLShortlist;

@interface SLAlbumArtImaging : NSObject

- (UIImage *)buildShortListAlbumArt:(SLShortlist *)shortlist;

@end
