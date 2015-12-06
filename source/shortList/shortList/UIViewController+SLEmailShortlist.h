//
//  UIViewController+SLEmailShortlist.h
//  shortList
//
//  Created by Dustin Bergman on 8/15/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLShortlist;

@interface UIViewController (SLEmailShortlist)

- (void)shareShortlistByEmail:(SLShortlist *)shortlist albumArtCollectionImage:(UIImage *)albumArtCollectionImage;
- (void)contactMeEmail;
@end
