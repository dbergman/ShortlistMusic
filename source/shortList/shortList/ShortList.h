//
//  ShortList.h
//  ShortList
//
//  Created by Dustin Bergman on 1/28/14.
//  Copyright (c) 2014 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AlbumShortList;

@interface ShortList : NSManagedObject

@property (nonatomic, retain) NSDate * shortListCreated;
@property (nonatomic, retain) NSString * shortListID;
@property (nonatomic, retain) NSString * shortListName;
@property (nonatomic, retain) NSString * shortListYear;
@property (nonatomic, retain) NSSet *album;
@end

@interface ShortList (CoreDataGeneratedAccessors)

- (void)addAlbumObject:(AlbumShortList *)value;
- (void)removeAlbumObject:(AlbumShortList *)value;
- (void)addAlbum:(NSSet *)values;
- (void)removeAlbum:(NSSet *)values;

@end
