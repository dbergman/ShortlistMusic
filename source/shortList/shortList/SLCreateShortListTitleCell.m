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
#import "Shortlist.h"

@interface SLCreateShortListTitleCell ()

@property (nonatomic, strong) UILabel *shortlistTitle;
@property (nonatomic, strong) UIToolbar *titleToolBar;

@end

@implementation SLCreateShortListTitleCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleToolBar = [UIToolbar new];
        self.titleToolBar.translucent = NO;
        self.titleToolBar.barTintColor = [UIColor blackColor];
        [self.titleToolBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.titleToolBar];

        self.shortlistTitle = [UILabel new];
        self.shortlistTitle.textAlignment = NSTextAlignmentCenter;
        self.shortlistTitle.backgroundColor = [UIColor clearColor];
        self.shortlistTitle.shadowColor = [UIColor sl_Red];
        self.shortlistTitle.shadowOffset = CGSizeMake(0, 1);
        self.shortlistTitle.textColor = [UIColor whiteColor];
        self.shortlistTitle.font = [UIFont boldSystemFontOfSize:20.0];
        UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:self.shortlistTitle];
        
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
        [cancelButton bk_initWithBarButtonSystemItem:UIBarButtonSystemItemStop handler:^(id sender) {
            if (weakSelf.cleanUpSLBlock) {
                weakSelf.cleanUpSLBlock();
            }
        }];
        
        NSArray *items = [[NSArray alloc] initWithObjects:marginSpace, cancelButton, flexibleSpace, toolBarTitle, flexibleSpace, createButton, marginSpace, nil];
        
        [self.titleToolBar setItems:items];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleToolBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleToolBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleToolBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1.0]];
    }
    
    return self;
}

- (void)configTitle:(Shortlist *)shortList {
    self.shortlistTitle.text = (shortList) ? NSLocalizedString(@"Update ShortList", nil) : NSLocalizedString(@"New ShortList", nil);
    [self.shortlistTitle sizeToFit];
    
    __weak typeof(self) weakSelf = self;
    UIBarButtonItem *rightButton = [UIBarButtonItem new];
    rightButton.tintColor = [UIColor whiteColor];
    [rightButton bk_initWithBarButtonSystemItem:(shortList) ? UIBarButtonSystemItemSave : UIBarButtonSystemItemAdd handler:^(id sender) {
        if (shortList) {
            if (weakSelf.updateSLBlock) {
                weakSelf.updateSLBlock();
            }
        }
        else {
            if (weakSelf.createSLBlock) {
                weakSelf.createSLBlock();
            }
        }
    }];
    
    NSMutableArray *barButtons = [self.titleToolBar.items mutableCopy];
    [barButtons replaceObjectAtIndex:barButtons.count - 2 withObject:rightButton];
     [self.titleToolBar setItems:[NSArray arrayWithArray:barButtons]];
}

@end
