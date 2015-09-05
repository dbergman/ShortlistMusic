//
//  SLPlayNowController.m
//  shortList
//
//  Created by Dustin Bergman on 8/8/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLPlayNowViewController.h"
#import "ItunesTrack.h"
#import "SLStyle.h"
#import "UIViewController+Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+AverageColor.h"

const CGFloat kSLPlayAlbumArtSize = 100.0;
const CGFloat kSLPlayButtonSize = 50.0;

@interface SLPlayNowViewController ()

@property (nonatomic, strong) ItunesTrack *albumDetails;
@property (nonatomic, strong) UILabel *albumTitleLabel;
@property (nonatomic, strong) UILabel *artistTitleLabel;
@property (nonatomic, strong) UIImageView *albumArtView;
@property (nonatomic, strong) UIButton *appleMusicButton;
@property (nonatomic, strong) UIButton *spotifyButton;

@end

@implementation SLPlayNowViewController

- (instancetype)initWithAlbum:(ItunesTrack *)albumDetails {
    self = [super init];
    if (self) {
        self.albumDetails = albumDetails;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.albumTitleLabel = [UILabel new];
    self.albumTitleLabel.text = self.albumDetails.collectionName;
    self.albumTitleLabel.numberOfLines = 0;
    self.albumTitleLabel.font = [SLStyle polarisFontWithSize:FontSizes.xLarge];
    
    self.artistTitleLabel = [UILabel new];
    self.artistTitleLabel.text = self.albumDetails.artistName;
    self.artistTitleLabel.numberOfLines = 0;
    self.artistTitleLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
    
    self.albumArtView = [UIImageView new];
    self.albumArtView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.appleMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.appleMusicButton setImage:[UIImage imageNamed:@"appleMusic"] forState:UIControlStateNormal];
    [self.appleMusicButton addTarget:self action:@selector(appleMusicAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.spotifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.spotifyButton setImage:[UIImage imageNamed:@"spotifyIcon"] forState:UIControlStateNormal];
    [self.spotifyButton addTarget:self action:@selector(spotifyAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *buttonContainer = [UIView new];
    
    for (UIView *sView in @[self.albumTitleLabel, self.artistTitleLabel, self.albumArtView, buttonContainer]) {
        sView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:sView];
    }
    
    for (UIView *sView in @[self.appleMusicButton, self.spotifyButton]) {
        sView.translatesAutoresizingMaskIntoConstraints = NO;
        [buttonContainer addSubview:sView];
    }
    
    __weak typeof(self)weakSelf = self;
    [self.albumArtView sd_setImageWithURL:[NSURL URLWithString:self.albumDetails.artworkUrl100] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf setBackgroundColor];
    }];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_albumArtView, _albumTitleLabel, _artistTitleLabel, buttonContainer, _appleMusicButton, _spotifyButton);
    NSDictionary *metrics = @{@"albumArtSize":@(kSLPlayAlbumArtSize), @"marginSmall":@(MarginSizes.small), @"buttonSize":@(kSLPlayButtonSize)};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-marginSmall-[_albumArtView(albumArtSize)]-[_albumTitleLabel]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-marginSmall-[_albumArtView(albumArtSize)]-[_artistTitleLabel]" options:0 metrics:metrics views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttonContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-marginSmall-[_albumArtView(albumArtSize)]-[buttonContainer]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-marginSmall-[_albumTitleLabel]-[_artistTitleLabel]" options:0 metrics:metrics views:views]];
    
    [buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_appleMusicButton(buttonSize)]|" options:0 metrics:metrics views:views]];
    
    if (self.albumDetails.spotifyDeepLink) {
        [buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_spotifyButton(buttonSize)]|" options:0 metrics:metrics views:views]];
        [buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_appleMusicButton(buttonSize)]-[_spotifyButton(buttonSize)]|" options:0 metrics:metrics views:views]];
    }
    else {
        self.spotifyButton.hidden = YES;
        [buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_appleMusicButton(buttonSize)]|" options:0 metrics:metrics views:views]];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.albumTitleLabel.preferredMaxLayoutWidth = self.view.frame.size.width - self.albumArtView.frame.size.width - (MarginSizes.small * 2.0);
    self.artistTitleLabel.preferredMaxLayoutWidth = self.albumTitleLabel.preferredMaxLayoutWidth;
}

- (void)spotifyAction {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.albumDetails.spotifyDeepLink]];
}

- (void)appleMusicAction {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.albumDetails.collectionViewUrl]];
}

#pragma mark - Coloring
- (void)setBackgroundColor {
    UIColor *color = [self.albumArtView.image averageColor];
    CGFloat hue = 0.0;
    [color getHue:&hue saturation:nil brightness:nil alpha:nil];
    self.view.backgroundColor = [[UIColor alloc] initWithHue:hue saturation:[self.albumDetails.trackCount intValue]/25.0 brightness:1.0 alpha:.9];
}

@end
