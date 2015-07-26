//
//  SLCreateShortListEnterYearCell.m
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLCreateShortListEnterYearCell.h"
#import "SLStyle.h"

@interface SLCreateShortListEnterYearCell () <UIPickerViewDelegate>

@property (nonatomic, strong) UILabel *shortListYearLabel;
@property (nonatomic, strong) UILabel *allYearLabel;
@property (nonatomic, strong) UIPickerView *yearPicker;
@property (nonatomic, strong) NSArray *yearFilterArray;

@end

@implementation SLCreateShortListEnterYearCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.shortListYearLabel = [UILabel new];
        [self.shortListYearLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.shortListYearLabel.text = NSLocalizedString(@"Filter Year:", nil);
        self.shortListYearLabel.numberOfLines = 2;
        self.shortListYearLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.shortListYearLabel.textColor = [UIColor whiteColor];
        [self.shortListYearLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.shortListYearLabel];
        
        self.yearPicker = [UIPickerView new];
        [self.yearPicker setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.yearPicker.delegate = self;
        self.yearPicker.backgroundColor = [UIColor clearColor];
        self.yearPicker.alpha = 0.0;
        [self.contentView addSubview:self.yearPicker];
        
        self.allYearLabel = [UILabel new];
        [self.allYearLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.allYearLabel.text = NSLocalizedString(@"All Years", nil);
        self.allYearLabel.textColor = [UIColor sl_Red];
        [self.allYearLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.allYearLabel];

        self.yearFilterArray = [self generateYearList];

        NSDictionary *views = NSDictionaryOfVariableBindings(_shortListYearLabel, _yearPicker, _allYearLabel);
        NSDictionary *metrics = @{@"margin":@(MarginSizes.medium), @"space":@(MarginSizes.small), @"pickerWidth":@(self.contentView.frame.size.width/3.0)};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_shortListYearLabel][_yearPicker(pickerWidth)]" options:0 metrics:metrics views:views]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shortListYearLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.yearPicker attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.yearPicker attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.allYearLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.allYearLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [UIView animateWithDuration:.2 delay:.2 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.allYearLabel.alpha = 0.0;
            self.yearPicker.alpha = 1.0;
        } completion:nil];
    }
}

- (void)hidePickerCell:(BOOL)clearResult {
    [UIView animateWithDuration:.2 delay:.2 options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (clearResult) {
            self.allYearLabel.alpha = 1.0;
            self.allYearLabel.text = NSLocalizedString(@"All Years", nil);
        }
        else {
            self.allYearLabel.text = self.yearFilterArray[[self.yearPicker selectedRowInComponent:0]];
        }
    } completion:^(BOOL finished) {
        if (clearResult) {
            [self.yearPicker selectRow:0 inComponent:0 animated:NO];
        }
    }];
}

#pragma mark - uipicker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        pickerLabel = [[UILabel alloc] init];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        pickerLabel.textColor = [UIColor whiteColor];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
    }
    [pickerLabel setText:[self.yearFilterArray objectAtIndex:row]];
    [pickerLabel sizeToFit];
    
    return pickerLabel;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.yearFilterArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.yearFilterArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.createYearAction) {
        self.createYearAction([self.yearFilterArray objectAtIndex:row]);
    }
}

- (NSArray *)generateYearList {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *theYear = [formatter stringFromDate:[NSDate date]];
    
    NSMutableArray *years = [[NSMutableArray alloc]init];
    [years addObject:@"All Years"];
    
    NSString *earlyYear = @"1959";
    
    while (![theYear isEqualToString: earlyYear]) {
        [years addObject:theYear];
        theYear = [NSString stringWithFormat:@"%d", [theYear intValue]-1];
    }
    
    return [years copy];
}

@end
