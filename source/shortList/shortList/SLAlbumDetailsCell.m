//
//  SLAlbumDetailsCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/10/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumDetailsCell.h"
#import "SLStyle.h"
#import "ItunesTrack.h"

@interface SLAlbumDetailsCell ()

@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UILabel *artistNameLabel;
@property (nonatomic, strong) UILabel *releaseYearLabel;
@property (nonatomic, strong) UILabel *trackCountLabel;

@end

@implementation SLAlbumDetailsCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
        
        self.albumNameLabel = [UILabel new];
        self.albumNameLabel.font = [SLStyle polarisFontWithSize:FontSizes.xLarge];
        self.albumNameLabel.numberOfLines = 1;
        
        self.artistNameLabel = [UILabel new];
        self.artistNameLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        
        self.releaseYearLabel = [UILabel new];
        self.releaseYearLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        
        self.trackCountLabel = [UILabel new];
        self.trackCountLabel.font = [SLStyle polarisFontWithSize:FontSizes.small];

        for (UILabel *cellLabel in @[self.albumNameLabel, self.artistNameLabel, self.releaseYearLabel, self.trackCountLabel ]) {
            [cellLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            cellLabel.textColor = [UIColor whiteColor];
            [self.contentView addSubview:cellLabel];
        }
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_albumNameLabel, _artistNameLabel, _releaseYearLabel, _trackCountLabel);
        NSDictionary *metrics = @{@"smallMargin":@(MarginSizes.small), @"labelWidth":@((self.contentView.frame.size.width- 2 * MarginSizes.small))};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_albumNameLabel(labelWidth)]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_artistNameLabel(labelWidth)]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_releaseYearLabel]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-smallMargin-[_albumNameLabel]-2-[_artistNameLabel]-2-[_releaseYearLabel]-smallMargin-|" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_trackCountLabel]-smallMargin-|" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_trackCountLabel]-smallMargin-|" options:0 metrics:metrics views:views]];
    }
    
    return self;
}

-(void)configureAlbumDetailCell:(ItunesTrack *)itunesTrack {
    self.albumNameLabel.text = [itunesTrack.collectionName uppercaseString];
    self.artistNameLabel.text = itunesTrack.artistName;
    self.releaseYearLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Release Year", nil), itunesTrack.releaseYear];
    self.trackCountLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Total Tracks", nil), itunesTrack.trackCount];
}

@end
