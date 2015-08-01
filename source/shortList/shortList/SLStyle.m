//
//  SLStyle.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLStyle.h"

#pragma mark - Structs
const struct MarginSizes MarginSizes = {
    .xSmall = 4.f,
    .small = 8.f,
    .medium = 12.f,
    .large = 16.f,
    .xLarge = 24.f,
    .xxLarge = 32.f
};

const struct FontSizes FontSizes = {
    .xSmall = 12.f,
    .small = 14.f,
    .medium = 15.f,
    .large = 16.f,
    .xLarge = 17.f
};

@implementation SLStyle

+ (UIFont *)polarisFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Polaris" size:size];
}

+ (UIFont *)nixonOneFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"NixieOne" size:size];
}

@end
