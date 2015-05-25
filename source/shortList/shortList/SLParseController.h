//
//  SLParseController.h
//  shortList
//
//  Created by Dustin Bergman on 5/24/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Shortlist;

@interface SLParseController : NSObject

+ (void)saveShortlist:(Shortlist *)newShortList;

@end
