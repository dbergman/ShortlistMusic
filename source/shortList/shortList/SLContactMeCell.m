//
//  SLContactMeCell.m
//  shortList
//
//  Created by Dustin Bergman on 11/24/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import "SLContactMeCell.h"
#import "SLStyle.h"

@interface SLContactMeCell ()

@property (nonatomic, strong) UIButton *contactMeButton;

@end

@implementation SLContactMeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        self.contactMeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.contactMeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contactMeButton setTitle:NSLocalizedString(@"Contact Me", nil) forState:UIControlStateNormal];
        [self.contactMeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.contactMeButton.titleLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        self.contactMeButton.backgroundColor = [UIColor grayColor];
        [self.contactMeButton addTarget:self action:@selector(contactMeButtonAction)forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.contactMeButton];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_contactMeButton);
        NSDictionary *metrics = @{};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_contactMeButton]-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_contactMeButton]-|" options:0 metrics:metrics views:views]];
    }
    
    return self;
}

- (void)contactMeButtonAction {
    if (self.contactMeBlockAction) {
        self.contactMeBlockAction();
    }
}

@end
