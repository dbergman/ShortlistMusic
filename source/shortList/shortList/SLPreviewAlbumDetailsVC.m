//
//  SLPreviewAlbumDetails.m
//  shortList
//
//  Created by Dustin Bergman on 1/10/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

#import "SLPreviewAlbumDetailsVC.h"
#import "SLShortListAlbum.h"
#import "SLStyle.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SLPreviewAlbumDetailsVC ()

@property (nonatomic, strong) UIImageView *albumArtImage;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, strong) SLShortListAlbum *shortListAlbum;

@end

@implementation SLPreviewAlbumDetailsVC

- (instancetype)initWithShortListAlbum:(SLShortListAlbum *)shortListAlbum {
    self = [super init];
    if (self) {
        self.shortListAlbum = shortListAlbum;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.albumArtImage = [UIImageView new];
    self.albumArtImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.albumArtImage sd_setImageWithURL:[NSURL URLWithString:self.shortListAlbum.albumArtWork]];
    self.albumArtImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.albumArtImage];
    
    self.albumNameLabel = [UILabel new];
    self.albumNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.albumNameLabel.font = [SLStyle polarisFontWithSize:FontSizes.xLarge];
    self.albumNameLabel.numberOfLines = 1;
    self.albumNameLabel.textColor = [UIColor blackColor];
    self.albumNameLabel.text = self.shortListAlbum.albumName;
    [self.view addSubview:self.albumNameLabel];
    
    self.artistNameLabel = [UILabel new];
    self.artistNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.artistNameLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
    self.artistNameLabel.textColor = [UIColor blackColor];
    self.artistNameLabel.text = self.shortListAlbum.artistName;
    [self.view addSubview:self.artistNameLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_albumArtImage, _albumNameLabel, _artistNameLabel);
    NSDictionary *metrics = @{@"albumArtworkSize":@(CGRectGetWidth([UIScreen mainScreen].bounds) - MarginSizes.xxLarge)};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_albumArtImage]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_albumArtImage]-[_albumNameLabel][_artistNameLabel]-|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
}

@end
