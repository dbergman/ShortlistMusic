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

@end

@implementation SLAlbumSearchResultsCellTableViewCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.albumArt = [UIImageView new];
        [self.albumArt setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.albumArt];
        
        self.albumNameLabel = [UILabel new];
        [self.albumNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.albumNameLabel.numberOfLines = 0;
        self.albumNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.albumNameLabel.textColor = [UIColor whiteColor];
        self.albumNameLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - kSLAlbumArtSize;
        [self.contentView addSubview:self.albumNameLabel];

        NSDictionary *views = NSDictionaryOfVariableBindings(_albumArt, _albumNameLabel);
        NSDictionary *metrics = @{@"albumArtSize":@(kSLAlbumArtSize), @"smallMargin":@(MarginSizes.small)};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_albumArt(albumArtSize)]-smallMargin-[_albumNameLabel]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-smallMargin-[_albumNameLabel]" options:0 metrics:metrics views:views]];
        
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumArt attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
    }
    
    return self;
}

- (void)configCellWithItunesAlbum:(ItunesAlbum *)album {
    [self.albumArt sd_setImageWithURL:[NSURL URLWithString:album.artworkUrl100] placeholderImage:nil];
    self.albumNameLabel.text = album.collectionName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
