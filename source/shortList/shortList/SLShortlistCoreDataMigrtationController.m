//
//  SLShortlistCoreDataMigrtationController.m
//  shortList
//
//  Created by Dustin Bergman on 11/29/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import "SLShortlistCoreDataMigrtationController.h"
#import "ShortList.h"
#import "SLShortlist.h"
#import "SLShortListAlbum.h"
#import "ShortListCoreDataManager.h"
#import "AlbumShortList.h"
#import "shortList-Swift.h"


@implementation SLShortlistCoreDataMigrtationController

- (void)addExistingShortListsToParse:(NSArray *)existingShortlists {
    for (ShortList *shortlist in existingShortlists) {
        [self createSLShortListWithExistingShortList:shortlist];
    }
}

- (void)createSLShortListWithExistingShortList:(ShortList *)existingSL {
    SLShortlist *newShortList = [SLShortlist new];
    newShortList.shortListName = existingSL.shortListName;
    newShortList.shortListYear = existingSL.shortListYear;
    
    __weak typeof(self)weakSelf = self;
    [SLParseController saveShortlist:newShortList completion:^{
        [weakSelf addExistingAlbums:[[ShortListCoreDataManager sharedManager] getShortListAlbums:existingSL] toShortlist:newShortList];
    }];
}

- (void)addExistingAlbums:(NSArray *)existingAlbums toShortlist:(SLShortlist *)shortlist {
    NSInteger rank = 1;
    for (AlbumShortList *album in existingAlbums) {
        if (album.albumCoverURL.length == 0) {
            return;
        }

        SLShortListAlbum *slAlbum = [SLShortListAlbum new];
        slAlbum.albumName = album.albumName;
        slAlbum.albumId = [album.albumID integerValue];
        slAlbum.releaseYear = album.albumYear;
        slAlbum.artistName = album.artistName;
        slAlbum.shortListRank = rank;
        slAlbum.albumArtWork = [album.albumCoverURL stringByReplacingOccurrencesOfString:@"100x100" withString:@"600x600"];
        slAlbum.shortListId = shortlist.objectId;
        
        [SLParseController addAlbumToShortList:slAlbum shortlist:shortlist completion:^{}];
        rank++;
    }
}

@end
