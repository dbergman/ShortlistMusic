//
//  SLPlayNowController.h
//  shortList
//
//  Created by Dustin Bergman on 8/8/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItunesTrack;

@interface SLPlayNowViewController : UIViewController

- (instancetype)initWithAlbum:(ItunesTrack *)albumDetails;

@end
