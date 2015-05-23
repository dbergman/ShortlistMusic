//
//  SLBannerView.h
//  shortList
//
//  Created by Dustin Bergman on 5/23/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SLBannerStyle) {
    SLBannerStyleDefault,
    SLBannerStyleSuccess,
    SLBannerStyleWarning,
    SLBannerStyleError
};

@interface SLBannerView : UIView

@property(nonatomic, weak) IBOutlet UIView *upperShadowView;
@property(nonatomic, weak) IBOutlet UIView *labelContainer;
@property(nonatomic, weak) IBOutlet UILabel *label;
@property(nonatomic, assign) BOOL visible;

/// Lifecycle
+ (instancetype)bannerViewWithMessage:(NSString *)message bannerStyle:(SLBannerStyle)bannerStyle;

/// Updates
- (void)setVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(SLBannerView *bannerView, BOOL finished))complete;


@end
