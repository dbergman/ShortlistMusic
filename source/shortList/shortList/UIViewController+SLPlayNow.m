//
//  UIViewController+SLPlayNow.m
//  shortList
//
//  Created by Dustin Bergman on 8/8/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLPlayNow.h"
#import "UIViewController+Utilities.h"
#import "SLPlayNowViewController.h"
#import "ItunesTrack.h"
#import "NSObject+BKAssociatedObjects.h"

static NSString * const kSLPlayerOptionVC = @"playerVC";

@implementation UIViewController (SLPlayNow)

- (void)buildPlayerViewControllerForAlbum:(ItunesTrack *)albumDetails {
    SLPlayNowViewController *playVC = [[SLPlayNowViewController alloc] initWithAlbum:albumDetails];
        
    CGRect frame = playVC.view.frame;
    frame.size = [playVC.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    playVC.view.frame = frame;
    [self setPlayerViewController:playVC];
    
    frame.origin = [self getOffScreenFrame].origin;
    playVC.view.frame = frame;
    
    [self.view addSubview:playVC.view];
    [self setPlayerViewController:playVC];
}

- (void)showPlayerView {
    [self.view bringSubviewToFront:[self playerViewController].view];
    
    [UIView animateWithDuration:.2 animations:^{
        [self playerViewController].view.frame = [self getOnScreenFrame];
    }];
}

- (void)hidePlayerView {
    [UIView animateWithDuration:.2 animations:^{
        [self playerViewController].view.frame = [self getOffScreenFrame];
    }];
}

- (CGRect)getOffScreenFrame {
    return CGRectMake(([self getScreenWidth]/2) - (([self playerViewController].view.frame.size.width)/2), - ([self getScreenHeight] * .3), [self playerViewController].view.frame.size.width, [self playerViewController].view.frame.size.height);
}

- (CGRect)getOnScreenFrame {
    return CGRectMake(([self getScreenWidth]/2) - (([self playerViewController].view.frame.size.width)/2), ([self getScreenHeight]/2) - (([self getScreenHeight] * .3)/2), [self playerViewController].view.frame.size.width, [self playerViewController].view.frame.size.height);
}

- (void)setPlayerViewController:(SLPlayNowViewController *)playerVC {
    [self bk_associateValue:playerVC withKey:@"playerVC"];
}

- (SLPlayNowViewController *)playerViewController {
    return [self bk_associatedValueForKey:@"playerVC"];
}

@end
