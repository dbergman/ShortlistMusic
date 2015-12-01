//
//  SLContactMeCell.m
//  shortList
//
//  Created by Dustin Bergman on 11/24/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import "SLGenericOneButtonCell.h"
#import "SLStyle.h"

@implementation SLGenericOneButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        self.oneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.oneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.oneButton setTitle:NSLocalizedString(@"Contact Me", nil) forState:UIControlStateNormal];
        [self.oneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.oneButton.titleLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        self.oneButton.backgroundColor = [UIColor grayColor];
        [self.oneButton addTarget:self action:@selector(oneButtonAction)forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.oneButton];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_oneButton);
        NSDictionary *metrics = @{};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_oneButton]-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_oneButton]-|" options:0 metrics:metrics views:views]];
    }
    
    return self;
}

- (void)oneButtonAction {
    if (self.buttonAction) {
        self.buttonAction();
    }
}

@end
