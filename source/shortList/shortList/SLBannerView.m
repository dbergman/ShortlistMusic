//
//  SLBannerView.m
//  shortList
//
//  Created by Dustin Bergman on 5/23/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLBannerView.h"

const CGFloat padding = 20;
const CGFloat shadowOffsetY = 2.0;
const CGFloat labelContainerMarginBottom = 8.0;

@interface SLBannerView ()

@property (assign) SLBannerStyle bannerStyle;

@end

@implementation SLBannerView

#pragma mark - Lifecycle
+ (instancetype)bannerViewWithMessage:(NSString *)message bannerStyle:(SLBannerStyle)bannerStyle {
    SLBannerView *banner = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SLBannerView class]) owner:nil options:nil][0];
    banner.bannerStyle = bannerStyle;
    [banner updateWithMessage:message];
    return banner;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    
    self.upperShadowView.backgroundColor = [UIColor blackColor];
    self.upperShadowView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    self.upperShadowView.layer.shadowOffset = CGSizeMake(0, shadowOffsetY);
    self.upperShadowView.layer.shadowOpacity = 0.0;
    self.upperShadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.upperShadowView.bounds].CGPath;
    
    self.labelContainer.backgroundColor = [UIColor blackColor];
    self.labelContainer.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    self.labelContainer.layer.shadowOffset = CGSizeMake(0, shadowOffsetY);
    self.labelContainer.layer.shadowOpacity = 0.0;
    self.labelContainer.layer.shadowRadius = 2;
    self.labelContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.labelContainer.bounds].CGPath;
    self.labelContainer.layer.actions = @{@"shadowPath": [NSNull null],
                                          @"shadowOpactiy" : [NSNull null]};
    
    self.labelContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"basket_confirmation_tile"]];
    
    self.label.backgroundColor = [UIColor clearColor];
  //  self.label.font = [UIFont fontWithStyle:ANTTextStyleLabel2];
}

- (void)updateWithMessage:(NSString *)message
{
    UIColor *textColor;
    UIColor *backgroundColor;
    UIFont *font;
    switch (self.bannerStyle) {
        case SLBannerStyleError:
            textColor = [UIColor whiteColor];
            backgroundColor = [UIColor redColor];
           // font = [UIFont fontWithStyle:ANTTextStyleErrorMessage];
            break;
        case SLBannerStyleSuccess:
        case SLBannerStyleWarning:
        default:
            textColor = [UIColor whiteColor];
            //backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"basket_confirmation_tile"]];
            //font = [UIFont fontWithStyle:ANTTextStyleLabel2];
            break;
    }
    self.label.font = font;
    self.label.textColor = textColor;
    self.labelContainer.backgroundColor = backgroundColor;
    
    self.label.text = message;
    [self updateContainerFrames];
}

- (void)updateContainerFrames
{
    CGFloat boundingWidth = (self.labelContainer.frame.size.width - (padding * 2));
    CGSize boundingSize = CGSizeMake(boundingWidth, MAXFLOAT);
    CGSize size = [self.label sizeThatFits:boundingSize];
    
    CGRect frame = self.frame;
    frame.size.height = (size.height + labelContainerMarginBottom + (padding * 2));
    self.frame = frame;
    self.labelContainer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - labelContainerMarginBottom);
    self.labelContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.labelContainer.bounds].CGPath;
    self.label.frame = CGRectMake(padding, padding, boundingWidth, size.height);
}

- (void)setVisible:(BOOL)visible
{
    [self setVisible:visible animated:NO completion:nil];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(SLBannerView *bannerView, BOOL finished))complete;
{
    _visible = visible;
    
    // If we're making this visible we should make sure the animation
    // starts in the right place. If it's becoming invisible, don't worry
    // about the starting point.
    if (visible) {
        CGRect frame = self.labelContainer.frame;
        frame.origin.y = -self.frame.size.height;
        self.labelContainer.frame = frame;
        self.labelContainer.layer.shadowOpacity = 1.0;
        self.upperShadowView.layer.shadowOpacity = 1.0;
    }
    
    CGFloat offsetY = visible ? 0 : -self.frame.size.height;
    void (^animation)() = ^(void) {
        CGRect frame = self.labelContainer.frame;
        frame.origin.y = offsetY;
        self.labelContainer.frame = frame;
    };
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:animation completion:^(BOOL finished) {
            if (complete) {
                complete(self, finished);
            }
        }];
    } else {
        animation();
        if (complete) {
            complete(self, YES);
        }
    }
}


@end
