//
//  AlbumShortList.h
//  ShortList
//
//  Created by Dustin Bergman on 3/1/14.
//  Copyright (c) 2014 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ShortList;

@interface AlbumShortList : NSManagedObject

@property (nonatomic, retain) NSString * albumCoverURL;
@property (nonatomic, retain) NSString * albumID;
@property (nonatomic, retain) NSString * albumName;
@property (nonatomic, retain) NSNumber * albumRank;
@property (nonatomic, retain) NSString * albumYear;
@property (nonatomic, retain) NSString * artistID;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSString * albumCopyRight;
@property (nonatomic, retain) ShortList *shortList;

@end
