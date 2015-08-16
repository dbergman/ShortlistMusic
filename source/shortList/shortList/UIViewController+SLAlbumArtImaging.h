//
//  UIViewController+SLAlbumArtImaging.h
//  shortList
//
//  Created by Dustin Bergman on 8/16/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Shortlist;

@interface UIViewController (SLAlbumArtImaging)

- (void)buildShortlistAlbumArtImage:(Shortlist *)shortlist;
- (UIImage *)getAlbumArtCollectionImage;

@end
