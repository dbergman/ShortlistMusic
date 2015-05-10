//
//  SLAlbumTrackCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/10/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumTrackCell.h"
#import "SLStyle.h"
#import "ItunesTrack.h"

@interface SLAlbumTrackCell ()

@property (nonatomic, strong) UILabel *trackNumberLabel;
@property (nonatomic, strong) UILabel *trackNameLabel;
@property (nonatomic, strong) UILabel *trackDurationLabel;

@end

@implementation SLAlbumTrackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.trackNumberLabel = [UILabel new];
        
        self.trackNameLabel = [UILabel new];
        self.trackNameLabel.numberOfLines = 2;
        self.trackNameLabel.preferredMaxLayoutWidth = self.contentView.frame.size.width - self.trackNumberLabel.frame.size.width - (2 * MarginSizes.small) - self.trackDurationLabel.frame.size.width;
        
        self.trackDurationLabel = [UILabel new];
        
        for (UILabel *cellLabel in @[self.trackDurationLabel, self.trackNameLabel, self.trackNumberLabel]) {
            [cellLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            cellLabel.textColor = [UIColor blackColor];
            [self.contentView addSubview:cellLabel];
        }
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_trackNumberLabel, _trackNameLabel, _trackDurationLabel);
        NSDictionary *metrics = @{@"smallMargin":@(MarginSizes.small)};

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-smallMargin-[_trackNumberLabel]-smallMargin-[_trackNameLabel]" options:0 metrics:metrics views:views]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.trackNumberLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_trackNameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.trackDurationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
   
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.trackDurationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-MarginSizes.small]];
    }
    
    return self;
}

-(void)configureAlbumTrackCell:(ItunesTrack *)itunesTrack {
    self.trackNumberLabel.text = [NSString stringWithFormat:@"%ld.", (long)itunesTrack.trackNumber];
    self.trackNameLabel.text = itunesTrack.trackName;
    self.trackDurationLabel.text = [NSString stringWithFormat:@"%@", itunesTrack.trackDuration];
}

@end
