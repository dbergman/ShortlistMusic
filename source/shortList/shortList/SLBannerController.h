//
//  SLBannerController.h
//  shortList
//
//  Created by Dustin Bergman on 5/23/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLBannerView.h"

typedef void(^SLBannerControllerTappedBlock)(void);

@interface SLBannerController : NSObject

+ (void)showBannerAtDefaultNavbarHeightWithMessage:(NSString *)message bannerStyle:(SLBannerStyle)bannerStyle tappedBlock:(SLBannerControllerTappedBlock)tappedBlock;

@end
