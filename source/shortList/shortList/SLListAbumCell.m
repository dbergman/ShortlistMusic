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
#import <SDWebImage/UIImageView+WebCache.h>

@interface SLListAbumCell ()

@property (nonatomic, strong) UIImageView *albumBackgroundImage;
@property (nonatomic, strong) FXBlurView *albumBlurView;

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
        
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_albumBackgroundImage, _albumBlurView);
        NSDictionary *metrics = @{};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumBackgroundImage]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumBackgroundImage(120)]|" options:0 metrics:metrics views:views]];
        
        [self.albumBackgroundImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumBlurView]|" options:0 metrics:metrics views:views]];
        [self.albumBackgroundImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumBlurView(120)]|" options:0 metrics:metrics views:views]];
        
//
//        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        
//        self.albumArt = [UIImageView new];
//        [self.albumArt setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [self.contentView addSubview:self.albumArt];
//        
//        self.albumNameLabel = [UILabel new];
//        [self.albumNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//        self.albumNameLabel.numberOfLines = 3;
//        self.albumNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        self.albumNameLabel.textColor = [UIColor whiteColor];
//        [self.contentView addSubview:self.albumNameLabel];
//        
//        self.albumReleaseYearLabel = [UILabel new];
//        [self.albumReleaseYearLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//        self.albumReleaseYearLabel.numberOfLines = 1;
//        self.albumReleaseYearLabel.textColor = [UIColor whiteColor];
//        [self.contentView addSubview:self.albumReleaseYearLabel];
//        
//        NSDictionary *views = NSDictionaryOfVariableBindings(_albumArt, _albumNameLabel, _albumReleaseYearLabel);
//        NSDictionary *metrics = @{@"albumArtSize":@(kSLAlbumArtSize), @"smallMargin":@(MarginSizes.small)};
//        
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_albumArt(albumArtSize)]-smallMargin-[_albumNameLabel]|" options:0 metrics:metrics views:views]];
//        
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_albumArt(albumArtSize)]-smallMargin-[_albumReleaseYearLabel]|" options:0 metrics:metrics views:views]];
//        
//        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumArt attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
//        
//        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.albumArt attribute:NSLayoutAttributeTop multiplier:1.0 constant:1.0]];
//        
//        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumReleaseYearLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.albumArt attribute:NSLayoutAttributeBottom multiplier:1.0 constant:1.0]];
    }
    
    return self;
}

- (void)layoutSubviews {
    
}

- (void)configureCell:(ShortListAlbum *)album {
    [self.albumBackgroundImage sd_setImageWithURL:[NSURL URLWithString:album.albumArtWork] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], self.contentView.frame);
        self.albumBackgroundImage.image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
    }];

}

@end
