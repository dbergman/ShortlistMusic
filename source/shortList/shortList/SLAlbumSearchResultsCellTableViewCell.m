//
//  SLAlbumSearchResultsCellTableViewCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumSearchResultsCellTableViewCell.h"
#import "SLStyle.h"
#import "ItunesAlbum.h"
#import <SDWebImage/UIImageView+WebCache.h>

static CGFloat const kSLAlbumArtSize = 100.0;

@interface SLAlbumSearchResultsCellTableViewCell ()

@property (nonatomic, strong) UIImageView *albumArt;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UILabel *albumReleaseYearLabel;

@end

@implementation SLAlbumSearchResultsCellTableViewCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        self.albumArt = [UIImageView new];
        [self.albumArt setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.albumArt];
        
        self.albumNameLabel = [UILabel new];
        [self.albumNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.albumNameLabel.numberOfLines = 3;
        self.albumNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.albumNameLabel.textColor = [UIColor whiteColor];
        self.albumNameLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - kSLAlbumArtSize;
        [self.contentView addSubview:self.albumNameLabel];
        
        self.albumReleaseYearLabel = [UILabel new];
        [self.albumReleaseYearLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.albumReleaseYearLabel.numberOfLines = 1;
        self.albumReleaseYearLabel.textColor = [UIColor whiteColor];
        self.albumReleaseYearLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - kSLAlbumArtSize;
        [self.contentView addSubview:self.albumReleaseYearLabel];

        NSDictionary *views = NSDictionaryOfVariableBindings(_albumArt, _albumNameLabel, _albumReleaseYearLabel);
        NSDictionary *metrics = @{@"albumArtSize":@(kSLAlbumArtSize), @"smallMargin":@(MarginSizes.small)};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_albumArt(albumArtSize)]-smallMargin-[_albumNameLabel]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_albumArt(albumArtSize)]-smallMargin-[_albumReleaseYearLabel]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumArt attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.albumArt attribute:NSLayoutAttributeTop multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumReleaseYearLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.albumArt attribute:NSLayoutAttributeBottom multiplier:1.0 constant:1.0]];
    }
    
    return self;
}

- (void)configCellWithItunesAlbum:(ItunesAlbum *)album {
    [self.albumArt sd_setImageWithURL:[NSURL URLWithString:album.artworkUrl100] placeholderImage:nil];
    self.albumNameLabel.text = album.collectionName;
    self.albumReleaseYearLabel.text = [NSString stringWithFormat:@"Release Year: %@", album.releaseYear];
}

@end
