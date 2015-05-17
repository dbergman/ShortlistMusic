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
        self.albumNameLabel.numberOfLines = 1;
        self.artistNameLabel = [UILabel new];
        self.releaseYearLabel = [UILabel new];
        self.trackCountLabel = [UILabel new];

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

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.albumNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.artistNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.albumNameLabel attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.releaseYearLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.artistNameLabel attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.trackCountLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.artistNameLabel attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.trackCountLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-MarginSizes.small]];
    }
    
    return self;
}

-(void)configureAlbumDetailCell:(ItunesTrack *)itunesTrack {
    self.albumNameLabel.text = itunesTrack.collectionName;
    self.artistNameLabel.text = itunesTrack.artistName;
    self.releaseYearLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Release Year", nil), itunesTrack.releaseYear];
    self.trackCountLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Total Tracks", nil), itunesTrack.trackCount];
}

@end
