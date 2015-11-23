//
//  UIColor+SLStyle.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIColor+SLStyle.h"

static NSString * const kSLStyleColorRed = @"#bb1717";
static NSString * const kSLStyleColorGreen = @"#009900";


@implementation UIColor (SLStyle)

+ (UIColor *)sl_Red {
    return [UIColor colorFromHexString:kSLStyleColorRed];
}

+ (UIColor *)sl_Green {
    return [UIColor colorFromHexString:kSLStyleColorGreen];
}

#pragma mark - Methods
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:(((rgbValue & 0xFF0000) >> 16) / 255.0f) green:(((rgbValue & 0xFF00) >> 8) / 255.0f) blue:((rgbValue & 0xFF) / 255.0f) alpha:1.0f];
}

@end
