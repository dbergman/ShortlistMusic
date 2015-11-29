//
//  ShortListCoreDataManager.h
//  ShortList
//
//  Created by Dustin Bergman on 3/16/14.
//  Copyright (c) 2014 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class ShortList, AlbumDetails, AlbumShortList;

@interface ShortListCoreDataManager : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedManager;
- (NSArray *)getAllShortLists;
- (NSMutableArray *)getShortListAlbums:(ShortList*)shortList;
- (ShortList *)getShortListByID:(ShortList *)shortList;
- (void)removeShortList:(ShortList*)shortList;
- (NSMutableArray *)updateShortList:(ShortList*)shortList withShortListAlbumArray:(NSMutableArray*)albumArray;
- (BOOL)isAlbum:(NSString*)albumID inShortList:(ShortList*)shortList;
- (ShortList *)createShortList:(NSString*)shortListName theYear:(NSString *)shortListYear;
- (void)updateShortList:(ShortList*)shortList withNewName:(NSString *)newShortListName andYear:(NSString*)newYear;
- (NSString*)generateID;
@end
