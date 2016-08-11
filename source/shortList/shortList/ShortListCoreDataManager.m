//
//  ShortListCoreDataManager.m
//  ShortList
//
//  Created by Dustin Bergman on 3/16/14.
//  Copyright (c) 2014 Dustin Bergman. All rights reserved.
//

#import "ShortListCoreDataManager.h"
#import "ShortList.h"
#import "AlbumShortList.h"
#include <stdlib.h>

@implementation ShortListCoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedManager {
    static ShortListCoreDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (ShortList *)createShortList:(NSString*)shortListName theYear:(NSString *)shortListYear {
    ShortList *shortList = [NSEntityDescription insertNewObjectForEntityForName:@"ShortList"
                                                      inManagedObjectContext:self.managedObjectContext];
    shortList.shortListName = shortListName;
    shortList.shortListYear = shortListYear;
    shortList.shortListID = [self generateID];

    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return shortList;
}

- (NSMutableArray *)getShortListAlbums:(ShortList*)shortList {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError* error;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AlbumShortList"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY shortList == %@", shortList];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"albumRank"
                                        ascending:YES];
    
    NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:descriptors];
    
    NSArray *shortListAlbums = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return  [shortListAlbums mutableCopy];
}

- (void)updateShortList:(ShortList*)shortList withNewName:(NSString *)newShortListName andYear:(NSString*)newYear {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError* error;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShortList"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *shortLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    ShortList *foundShortList;
    for (ShortList *sl in shortLists) {
        if ([sl.shortListID isEqualToString:shortList.shortListID]) {
            foundShortList = sl;
            break;
        }
    }
    foundShortList.shortListName = newShortListName;
    foundShortList.shortListYear = newYear;

    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

//Use this to get updated shortlist name when updating
-(ShortList *)getShortListByID:(ShortList *)shortList {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError* error;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShortList"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *shortLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    ShortList *foundShortList;
    for (ShortList *sl in shortLists) {
        if ([sl.shortListID isEqualToString:shortList.shortListID]) {
            foundShortList = sl;
            break;
        }
    }
    
    return foundShortList;
}

- (void)removeShortList:(ShortList*)shortList {

    [self.managedObjectContext deleteObject:shortList];
    [self.managedObjectContext processPendingChanges];
    NSError* error = nil;
    [self.managedObjectContext save:&error];
    
}

-(NSArray *)getAllShortLists {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShortList"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    NSArray *allAlbums = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return allAlbums;
}

-(BOOL)isAlbum:(NSString*)albumID inShortList:(ShortList*)shortList {
    BOOL alreadyAdded = NO;
    NSMutableArray *shortListAlbums = [self getShortListAlbums:shortList];
    for(AlbumShortList* sAlbum in shortListAlbums)
    {
        if([sAlbum.albumID isEqualToString:albumID])
            alreadyAdded = YES;
    }
    return alreadyAdded;
}

- (NSMutableArray *)removeAlbum:(AlbumShortList*)removeAlbum inShortList:(ShortList*)shortList withShortListAlbumArray:(NSMutableArray*)albumArray {
     NSMutableArray *shortListAlbums = [self getShortListAlbums:shortList];

    for (AlbumShortList *album in shortListAlbums) {
        if([removeAlbum.albumID isEqualToString:album.albumID]){
         [self.managedObjectContext deleteObject:album];
         break;
        }
      }
    NSError *error;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return [self updateShortList:shortList withShortListAlbumArray:[self getShortListAlbums:shortList]];
}

- (NSMutableArray *)updateShortList:(ShortList*)shortList withShortListAlbumArray:(NSMutableArray*)albumArray {
    NSFetchRequest *fetchRequest;
    NSError* error;
    int rank = 1;
    for (AlbumShortList *album in albumArray) {
        
        fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *shortListAlbum = [NSEntityDescription entityForName:@"AlbumShortList"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:shortListAlbum];
    
        NSMutableArray *parr = [NSMutableArray array];
        [parr addObject:[NSPredicate predicateWithFormat:@"ANY shortList == %@", shortList]];
        [parr addObject:[NSPredicate predicateWithFormat:@"ANY albumID == %@", album.albumID]];

        NSPredicate *compoundpred = [NSCompoundPredicate andPredicateWithSubpredicates:parr];
        [fetchRequest setPredicate:compoundpred];
        
        NSArray *albumsLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (AlbumShortList *tryAlbum in albumsLists) {
            if([tryAlbum.albumID isEqualToString:album.albumID])
            {
                tryAlbum.albumRank =  [NSNumber numberWithInt:rank];
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
                rank++;
            }
        }
    }
    return [self getShortListAlbums:shortList];
}

-(NSNumber *)getCurrentRank:(NSArray*)shortListAlbums {
    if(shortListAlbums.count == 0)
        return 0;
    
    int highRank = (int)[[[shortListAlbums objectAtIndex:0]albumRank] integerValue];
    
    for(AlbumShortList* album in shortListAlbums)
    {
        if(highRank < [album.albumRank integerValue])
            highRank = (int)[album.albumRank integerValue];
    }
    return [NSNumber numberWithInt:highRank];
}

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"ShortListCoreDataTrial.sqlite"]];

    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString*)generateID {
    NSArray *shortListsArray = [self getAllShortLists];
    NSMutableArray *shortListIDs = [[NSMutableArray alloc]init];
    
    for (ShortList *sl in  shortListsArray) {
        if (sl.shortListID != nil)
            [shortListIDs addObject:sl.shortListID];
    }
    
    int randID = arc4random() % 1000;
    NSString* randIDStr = [NSString stringWithFormat:@"%d", randID];
    
    if([shortListIDs containsObject:randIDStr])
        [self generateID];
    
    return randIDStr;
}

@end
