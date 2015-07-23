//
//  SLAlbumCell.m
//  shortList
//
//  Created by Dustin Bergman on 7/20/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumCell.h"
#import "ShortListAlbum.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SLAlbumCell ()

@property (nonatomic, strong) UIImageView *albumArtView;

@end

@implementation SLAlbumCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {        
        self.albumArtView = [UIImageView new];
        self.albumArtView.contentMode = UIViewContentModeScaleAspectFit;
        self.albumArtView.backgroundColor = [UIColor purpleColor];
        self.albumArtView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.albumArtView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_albumArtView);
        NSDictionary *metrics = @{};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumArtView]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumArtView]|" options:0 metrics:metrics views:views]];
    }
    
    return self;
}

- (void)configWithShortListAlbum:(ShortListAlbum *)albums {
    [self.albumArtView sd_setImageWithURL:[NSURL URLWithString:albums.albumArtWork]];
}


@end
