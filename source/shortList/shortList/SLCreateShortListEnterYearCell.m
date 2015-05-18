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
        self.shortListYearLabel.text = NSLocalizedString(@"ShortList Year:", nil);
        self.shortListYearLabel.textColor = [UIColor whiteColor];
        [self.shortListYearLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.shortListYearLabel];
        
        self.yearPicker = [UIPickerView new];
        [self.yearPicker setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.yearPicker.delegate = self;
        self.yearPicker.backgroundColor = [UIColor clearColor];
        self.yearPicker.alpha = 0.0;
        [self.contentView addSubview:self.yearPicker];
        
        self.yearFilterArray = [self generateYearList];

        NSDictionary *views = NSDictionaryOfVariableBindings(_shortListYearLabel, _yearPicker);
        NSDictionary *metrics = @{@"margin":@(MarginSizes.medium), @"space":@(MarginSizes.small)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_shortListYearLabel][_yearPicker]" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_shortListYearLabel][_yearPicker]|" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shortListYearLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [UIView animateWithDuration:.2 delay:.2 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.yearPicker.alpha = 1.0;
        } completion:nil];
    }
    
}

#pragma mark - uipicker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, 80, 32);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        pickerLabel.textColor = [UIColor whiteColor];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
    }
    [pickerLabel setText:[self.yearFilterArray objectAtIndex:row]];
    
    return pickerLabel;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.yearFilterArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.yearFilterArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
   // self.selectedYearLabel.text = [self.yearFilterArray objectAtIndex:row];
}

- (NSArray *)generateYearList {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *theYear = [formatter stringFromDate:[NSDate date]];
    
    NSMutableArray *years = [[NSMutableArray alloc]init];
    [years addObject:@"All"];
    
    NSString *earlyYear = @"1960";
    
    while (![theYear isEqualToString: earlyYear]) {
        [years addObject:theYear];
        theYear = [NSString stringWithFormat:@"%d", [theYear intValue]-1];
    }
    
    return [years copy];
}

@end
