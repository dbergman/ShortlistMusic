//
//  UIViewController+SLEmailShortlist.h
//  shortList
//
//  Created by Dustin Bergman on 8/15/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Shortlist;

@interface UIViewController (SLEmailShortlist)

- (void)shareShortlistByEmail:(Shortlist *)shortlist albumArtCollectionImage:(UIImage *)albumArtCollectionImage;

@end
