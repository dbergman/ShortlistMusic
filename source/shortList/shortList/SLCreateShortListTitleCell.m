//
//  SLCreateShortListTitleCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLCreateShortListTitleCell.h"

@implementation SLCreateShortListTitleCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *createTitleLabel = [UILabel new];
        [createTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        createTitleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:createTitleLabel];
        
        createTitleLabel.text = NSLocalizedString(@"Create a new ShortList", nil);
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:createTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:createTitleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
    }
    
    return self;
}

@end
