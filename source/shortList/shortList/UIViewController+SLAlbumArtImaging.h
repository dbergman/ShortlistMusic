//
//  UIViewController+SLAlbumArtImaging.h
//  shortList
//
//  Created by Dustin Bergman on 8/16/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLShortlist;

@interface UIViewController (SLAlbumArtImaging)

- (void)buildShortlistAlbumArtImage;
- (UIImage *)getAlbumArtCollectionImage;
- (void)loadCollectionViewImage:(SLShortlist *)shortlist;

@end
