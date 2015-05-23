//
//  SLBannerController.m
//  shortList
//
//  Created by Dustin Bergman on 5/23/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLBannerController.h"
#import <BlocksKit+UIKit.h>

const CGFloat defaultNavBarHeight = 64;
static NSMutableArray *queue;

BOOL bannerVisible = NO;

static NSInteger const baseLength = 20;
static NSInteger const growthLimitingNumber = 3;
static CGFloat const baseDelay = 3.0f;
static CGFloat const delayPerCharacter = baseDelay / baseLength;

@interface SLBannerConfig : NSObject
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) CGFloat startHeight;
@property (nonatomic, assign) SLBannerStyle bannerStyle;
@property (nonatomic, copy) SLBannerControllerTappedBlock tappedBlock;
@end

@implementation SLBannerConfig
@end

@implementation SLBannerController

+ (void)showBannerAtDefaultNavbarHeightWithMessage:(NSString *)message bannerStyle:(SLBannerStyle)bannerStyle tappedBlock:(SLBannerControllerTappedBlock)tappedBlock {
    [self showBannerAtHeight:defaultNavBarHeight withMessage:message bannerStyle:bannerStyle tappedBlock:tappedBlock];
}

+ (void)showBannerAtHeight:(CGFloat)height withMessage:(NSString *)message bannerStyle:(SLBannerStyle)bannerStyle tappedBlock:(SLBannerControllerTappedBlock)tappedBlock {
    // If we're already displaying a banner, queue up this method call.
    if (bannerVisible) {
        SLBannerConfig *c = [SLBannerConfig new];
        c.message = message;
        c.bannerStyle = bannerStyle;
        c.tappedBlock = tappedBlock;
        c.startHeight = height;
        [self enqueueConfig:c];
        return;
    }
    
    bannerVisible = YES;
    UIWindow *window = [[UIApplication sharedApplication] windows][0];
    SLBannerView *banner = [SLBannerView bannerViewWithMessage:message bannerStyle:bannerStyle];
    
    CGRect frame = banner.frame;
    frame.origin.y = height;
    banner.frame = frame;
    [window addSubview:banner];
    
    __weak typeof(self) weakSelf = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (tappedBlock) {
            tappedBlock();
        }
        [weakSelf dismissBanner:sender];
    }];
    [banner addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [self dismissBanner:sender];
    }];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [banner addGestureRecognizer:swipe];
    
    CGFloat delay = [weakSelf delayForMessage:message];
    
    [banner setVisible:YES animated:YES completion:^(SLBannerView *bannerView, BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatchAfterDelayInSeconds(delay, dispatch_get_main_queue(), ^{
            [strongSelf dismissBanner:tap];
        });
    }];
}

+ (CGFloat)delayForMessage:(NSString *)message {
    /* This is a method to calculate time to show for a banner based on its length, some rules, and testing with Lauren
     * Minimum time to show banner is baseLength seconds
     * Since the shortest message is currently about baseLength characters long, take baseLength to be a base length
     * The base delay divided by base length is the starting point for seconds per character
     * After some testing with Lauren, this was too long for the longer messages, so the amount added is divided by growthLimitingNumber
     * These numbers might be changed with further testing
     */
    
    NSInteger numberOfCharactersOverBaseLength = MAX(message.length - baseLength, 0);
    CGFloat delay = baseDelay + (delayPerCharacter * numberOfCharactersOverBaseLength) / growthLimitingNumber;
    
    return delay;
}

+ (void)dismissBanner:(UIGestureRecognizer *)gr {
    SLBannerView *banner = (SLBannerView *)gr.view;
    [banner setVisible:NO animated:YES completion:^(SLBannerView *bannerView, BOOL finished) {
        bannerVisible = NO;
        [bannerView removeFromSuperview];
        
        SLBannerConfig *queuedConfig = [self dequeueConfig];
        if(queuedConfig)
            [self showBannerAtHeight:queuedConfig.startHeight withMessage:queuedConfig.message bannerStyle:queuedConfig.bannerStyle tappedBlock:queuedConfig.tappedBlock];
    }];
}

+ (void)enqueueConfig:(SLBannerConfig *)config {
    if (!queue) {
        queue = [[NSMutableArray alloc] init];
    }
    
    [queue addObject:config];
}

+ (SLBannerConfig *)dequeueConfig {
    SLBannerConfig *queuedConfig = [queue firstObject];
    if (queuedConfig) {
        [queue removeObjectAtIndex:0];
    }
    
    return queuedConfig;
}

@end
