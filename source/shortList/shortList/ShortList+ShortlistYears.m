//
//  ShortList+ShortlistYears.m
//  shortList
//
//  Created by Dustin Bergman on 8/6/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

#import "ShortList+ShortlistYears.h"

@implementation ShortList (ShortlistYears)

+ (NSArray *)generateYearList {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *theYear = [formatter stringFromDate:[NSDate date]];
    
    NSMutableArray *years = [[NSMutableArray alloc]init];
    [years addObject:@"All"];
    
    NSString *earlyYear = @"1959";
    
    while (![theYear isEqualToString: earlyYear]) {
        [years addObject:theYear];
        theYear = [NSString stringWithFormat:@"%d", [theYear intValue]-1];
    }
    
    return [years copy];
}

@end
