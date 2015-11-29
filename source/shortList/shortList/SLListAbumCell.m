//
//  SLListAbumCell.m
//  shortList
//
//  Created by Dustin Bergman on 7/7/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLListAbumCell.h"
#import "SLShortListAlbum.h"
#import "SLStyle.h"
#import "UIImage+ImageEffects.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kSLALbumCellHeight = 120;

@interface SLListAbumCell ()

@property (nonatomic, strong) UIImageView *albumBackgroundImage;
@property (nonatomic, strong) UILabel *albumTitleLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, strong) UILabel *albumRankLabel;

@end

@implementation SLListAbumCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.shouldIndentWhileEditing = NO;
        
        self.albumBackgroundImage = [UIImageView new];
        self.albumBackgroundImage.clipsToBounds = YES;
        [self.albumBackgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.albumBackgroundImage];

        UIView *shortListDetailContainer = [UIView new];
        [self.contentView addSubview:shortListDetailContainer];
        
        self.albumTitleLabel = [UILabel new];
        self.albumTitleLabel.numberOfLines = 2;
        self.albumTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.albumTitleLabel.font = [SLStyle polarisFontWithSize:FontSizes.xLarge];
        self.albumTitleLabel.textColor = [UIColor whiteColor];
        [shortListDetailContainer addSubview:self.albumTitleLabel];
        
        self.albumRankLabel = [UILabel new];
        self.albumRankLabel.textColor = [UIColor whiteColor];
        self.albumRankLabel.font = [SLStyle polarisFontWithSize:FontSizes.large];
        [shortListDetailContainer addSubview:self.albumRankLabel];
        
        self.artistNameLabel = [UILabel new];
        self.artistNameLabel.numberOfLines = 2;
        self.artistNameLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        self.artistNameLabel.textAlignment = NSTextAlignmentCenter;
        self.artistNameLabel.textColor = [UIColor whiteColor];
        [shortListDetailContainer addSubview:self.artistNameLabel];
        
        for (UIView *view in @[self.artistNameLabel, self.albumRankLabel, self.albumTitleLabel, self.albumBackgroundImage, shortListDetailContainer]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }

        NSDictionary *views = NSDictionaryOfVariableBindings(_albumBackgroundImage, _albumTitleLabel, _albumRankLabel, _artistNameLabel, shortListDetailContainer);
        NSDictionary *metrics = @{@"height":@(kSLALbumCellHeight)};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumBackgroundImage]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumBackgroundImage(height)]|" options:0 metrics:metrics views:views]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:shortListDetailContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:shortListDetailContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

        [shortListDetailContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumRankLabel]-[_albumTitleLabel]|" options:0 metrics:metrics views:views]];
        
        [shortListDetailContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_artistNameLabel]|" options:0 metrics:metrics views:views]];

        [shortListDetailContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumRankLabel]" options:0 metrics:metrics views:views]];
        
        [shortListDetailContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumTitleLabel][_artistNameLabel]|" options:0 metrics:metrics views:views]];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.albumTitleLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - (2.0 * MarginSizes.xLarge);
    self.artistNameLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - (2.0 * MarginSizes.xLarge);
}

- (void)configureCell:(SLShortListAlbum *)album {
    __weak typeof(self)weakSelf = self;
    [self.albumBackgroundImage sd_setImageWithURL:[NSURL URLWithString:album.albumArtWork] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        UIImage *blurArtwork = [image applyBlurWithRadius:20 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.2] saturationDeltaFactor:1.0 maskImage:nil];
        weakSelf.albumBackgroundImage.image = blurArtwork;
    }];
    
    self.artistNameLabel.text = album.artistName;
    self.albumRankLabel.text = [NSString stringWithFormat:@"%ld.", (long)album.shortListRank];
    self.albumTitleLabel.text = [album.albumName uppercaseString];
}

@end
