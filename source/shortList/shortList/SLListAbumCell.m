//
//  SLListAbumCell.m
//  shortList
//
//  Created by Dustin Bergman on 7/7/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLListAbumCell.h"
#import "ShortListAlbum.h"
#import "FXBlurView.h"
#import "SLStyle.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kSLALbumCellHeight = 120;

@interface SLListAbumCell ()

@property (nonatomic, strong) UIImageView *albumBackgroundImage;
@property (nonatomic, strong) FXBlurView *albumBlurView;
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
        
        self.albumBackgroundImage = [UIImageView new];
        self.albumBackgroundImage.clipsToBounds = YES;
        [self.albumBackgroundImage setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.albumBackgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.albumBackgroundImage];
        
        self.albumBlurView = [[FXBlurView alloc] init];
        self.albumBlurView.tintColor = [UIColor blackColor];
        self.albumBlurView.blurEnabled = YES;
        self.albumBlurView.translatesAutoresizingMaskIntoConstraints = NO;
        self.albumBlurView.clipsToBounds = YES;
        self.albumBlurView.blurRadius = 8;
        [self.albumBackgroundImage addSubview:self.albumBlurView];
        
        UIView *overlay = [UIView new];
        overlay.translatesAutoresizingMaskIntoConstraints = NO;
        overlay.backgroundColor = [UIColor blackColor];
        overlay.alpha = .4;
        [self.albumBlurView addSubview:overlay];
        
        UIView *shortListDetailContainer = [UIView new];
        shortListDetailContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:shortListDetailContainer];
        
        self.albumTitleLabel = [UILabel new];
        self.albumTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.albumTitleLabel.numberOfLines = 2;
        self.albumTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.albumTitleLabel.textColor = [UIColor whiteColor];
        [shortListDetailContainer addSubview:self.albumTitleLabel];
        
        self.albumRankLabel = [UILabel new];
        self.albumRankLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.albumRankLabel.textColor = [UIColor whiteColor];
        [shortListDetailContainer addSubview:self.albumRankLabel];
        
        self.artistNameLabel = [UILabel new];
        self.artistNameLabel.numberOfLines = 2;
        self.artistNameLabel.textAlignment = NSTextAlignmentCenter;
        self.artistNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.artistNameLabel.textColor = [UIColor whiteColor];
        [shortListDetailContainer addSubview:self.artistNameLabel];

        NSDictionary *views = NSDictionaryOfVariableBindings(_albumBackgroundImage, _albumBlurView, overlay, _albumTitleLabel, _albumRankLabel, _artistNameLabel, shortListDetailContainer);
        NSDictionary *metrics = @{@"height":@(kSLALbumCellHeight)};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumBackgroundImage]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumBackgroundImage(height)]|" options:0 metrics:metrics views:views]];
        
        [self.albumBackgroundImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumBlurView]|" options:0 metrics:metrics views:views]];
        [self.albumBackgroundImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumBlurView]|" options:0 metrics:metrics views:views]];
        
        [self.albumBlurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlay]|" options:0 metrics:metrics views:views]];
        [self.albumBlurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlay]|" options:0 metrics:metrics views:views]];
        
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

    self.albumTitleLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - (1.0 * MarginSizes.large);
    self.artistNameLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - (1.0 * MarginSizes.large);
}

- (void)configureCell:(ShortListAlbum *)album {
    [self.albumBackgroundImage sd_setImageWithURL:[NSURL URLWithString:album.albumArtWork] completed:nil];
    self.artistNameLabel.text = album.artistName;
    self.albumRankLabel.text = @"1.";
    self.albumTitleLabel.text = album.albumName;
}

@end
