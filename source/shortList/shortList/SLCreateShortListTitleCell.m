//
//  SLCreateShortListTitleCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLCreateShortListTitleCell.h"
#import "SLStyle.h"
#import <BlocksKit+UIKit.h>

@implementation SLCreateShortListTitleCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIToolbar *titleToolBar = [UIToolbar new];
        titleToolBar.translucent = NO;
        titleToolBar.barTintColor = [UIColor blackColor];
        [titleToolBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:titleToolBar];

        UILabel *shortlistTitle = [UILabel new];
        shortlistTitle.textAlignment = NSTextAlignmentCenter;
        shortlistTitle.backgroundColor = [UIColor clearColor];
        shortlistTitle.shadowColor = [UIColor sl_Red];
        shortlistTitle.shadowOffset = CGSizeMake(0, 1);
        shortlistTitle.textColor = [UIColor whiteColor];
        shortlistTitle.text = NSLocalizedString(@"New ShortList", nil);
        shortlistTitle.font = [UIFont boldSystemFontOfSize:20.0];
        [shortlistTitle sizeToFit];
        UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:shortlistTitle];
        
        UIBarButtonItem *marginSpace =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        marginSpace.width = 15;
        
        UIBarButtonItem *flexibleSpace =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        __weak typeof(self) weakSelf = self;
        UIBarButtonItem *createButton = [UIBarButtonItem new];
        createButton.tintColor = [UIColor whiteColor];
        [createButton bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
            if (weakSelf.createSLBlock) {
                weakSelf.createSLBlock();
            }
        }];
    
        UIBarButtonItem *cancelButton = [UIBarButtonItem new];
        cancelButton.tintColor = [UIColor sl_Red];
        [cancelButton bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
            if (weakSelf.cleanUpSLBlock) {
                weakSelf.cleanUpSLBlock();
            }
        }];
        
        NSArray *items = [[NSArray alloc] initWithObjects:marginSpace, cancelButton, flexibleSpace, toolBarTitle, flexibleSpace, createButton, marginSpace, nil];
        
        [titleToolBar setItems:items];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:titleToolBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:titleToolBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:titleToolBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
    }
    
    return self;
}

@end
