//
//  SLCreateShortListEnterName.m
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLCreateShortListEnterNameCell.h"
#import "SLStyle.h"
#import <QuartzCore/QuartzCore.h>

@interface SLCreateShortListEnterNameCell () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *shortListNameLabel;
@property (nonatomic, strong) UITextField *shortListNameTextfield;

@end

@implementation SLCreateShortListEnterNameCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.shortListNameLabel = [UILabel new];
        [self.shortListNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.shortListNameLabel.text = NSLocalizedString(@"ShortList Name:", nil);
        self.shortListNameLabel.numberOfLines = 2;
        self.shortListNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.shortListNameLabel.textColor = [UIColor whiteColor];
        [self.shortListNameLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.shortListNameLabel];
        
        self.shortListNameTextfield = [UITextField new];
        self.shortListNameTextfield.delegate = self;
        [self.shortListNameTextfield setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.shortListNameTextfield.layer.cornerRadius= 3.0f;
        self.shortListNameTextfield.layer.masksToBounds = YES;
        self.shortListNameTextfield.backgroundColor = [UIColor whiteColor];
        [self.shortListNameTextfield setTintColor:[UIColor sl_Red]];
        [self.contentView addSubview:self.shortListNameTextfield];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_shortListNameLabel, _shortListNameTextfield);
        NSDictionary *metrics = @{@"margin":@(MarginSizes.medium), @"space":@(MarginSizes.small)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_shortListNameLabel]-space-[_shortListNameTextfield]-margin-|" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shortListNameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shortListNameTextfield attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    
    return self;
}

- (void)clearShortListName {
    self.shortListNameTextfield.text = [NSString new];
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *currentShortListName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (self.createNameAction) {
        self.createNameAction(currentShortListName);
    }

    return YES;
}

@end
