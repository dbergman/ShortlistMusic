//
//  SLAlbumSearchResultsCellTableViewCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumSearchResultsCellTableViewCell.h"
#import "ItunesAlbum.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SLAlbumSearchResultsCellTableViewCell ()

@property (nonatomic, strong) UIImageView *albumArt;

@end

@implementation SLAlbumSearchResultsCellTableViewCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.albumArt = [UIImageView new];
        [self.albumArt setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.albumArt];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_albumArt);
        NSDictionary *metrics = @{@"albumArtSize":@100};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_albumArt(albumArtSize)]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumArt attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];        
    }
    
    return self;
}

- (void)configCellWithItunesAlbum:(ItunesAlbum *)album {
    [self.albumArt sd_setImageWithURL:[NSURL URLWithString:album.artworkUrl100] placeholderImage:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
