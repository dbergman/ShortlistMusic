//
//  SLCreateShortListButtonCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLCreateShortListButtonCell.h"
#import "SLStyle.h"
#import <BlocksKit+UIKit.h>

@interface SLCreateShortListButtonCell ()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *createButton;

@end

@implementation SLCreateShortListButtonCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor sl_Red];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.cancelButton.titleLabel.textColor = [UIColor whiteColor];
        self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.cancelButton];
        [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor sl_Red] forState:UIControlStateHighlighted];
        self.cancelButton.backgroundColor = [UIColor blackColor];
        
        __weak typeof(self) weakSelf = self;
        [self.cancelButton bk_addEventHandler:^(id sender) {
            if (weakSelf.cleanUpSLBlock) {
                weakSelf.cleanUpSLBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        self.createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.createButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.createButton.titleLabel.textColor = [UIColor whiteColor];
        self.createButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.createButton];
        [self.createButton setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
        [self.createButton setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
        self.createButton.backgroundColor = [UIColor blackColor];
        
        [self.createButton bk_addEventHandler:^(id sender) {
            if (weakSelf.createSLBlock) {
                weakSelf.createSLBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_cancelButton, _createButton);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cancelButton(_createButton)]-1-[_createButton]|" options:0 metrics:nil views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_createButton]|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cancelButton]|" options:0 metrics:nil views:views]];
        
    }
    
    return self;
}

@end
