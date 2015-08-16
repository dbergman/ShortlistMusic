//
//  SLInstagramController.h
//  shortList
//
//  Created by Dustin Bergman on 8/16/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class Shortlist;

@interface SLInstagramController : NSObject

+ (id)sharedInstance;
- (void)shareShortlistToInstagram:(Shortlist *)shortlist albumArtCollectionImage:(UIImage *)albumArtCollectionImage attachToView:(UIView *)attachView;

@end
