//
//  Shortlist.h
//  shortList
//
//  Created by Dustin Bergman on 5/24/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Parse/Parse.h>
@class SLShortListAlbum;

@interface SLShortlist : PFObject <PFSubclassing, NSSecureCoding>

@property (nonatomic, strong) NSString *shortListName;
@property (nonatomic, strong) NSString *shortListYear;
@property (nonatomic, strong) NSString *shortListUserId;
@property (nonatomic, strong) NSArray<SLShortListAlbum*> *shortListAlbums;

@end
