//
//  SLAlbumArtImaging.m
//  shortList
//
//  Created by Dustin Bergman on 8/18/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumArtImaging.h"
#import "Shortlist.h"
#import "ShortListAlbum.h"

static NSString * const kShortListAlbumArtKey = @"slAlbumImage";
static NSString * const kShortListAlbumRankKey = @"slAlbumRank";
static const CGFloat kShortListAlbumArtWorkSize = 320.0;

@implementation SLAlbumArtImaging

- (UIImage *)buildShortListAlbumArt:(Shortlist *)shortlist {
    NSOperationQueue *queue = [NSOperationQueue new];
    NSMutableArray *operationArray = [NSMutableArray new];
    
    NSMutableArray *albumArtArray = [NSMutableArray new];
    
    __weak typeof(self)weakSelf = self;
    for (ShortListAlbum *slAlbum in shortlist.shortListAlbums) {
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
           [albumArtArray addObject:[weakSelf downloadAlbumImage:slAlbum]];
        }];
        [operationArray addObject:op];
    }
    
    queue.maxConcurrentOperationCount = 3;
    [queue addOperations:operationArray waitUntilFinished:YES];
    
    UIImage *collectionImage = [self buildTheImage:albumArtArray];
 
    return collectionImage;
}

- (NSDictionary *)downloadAlbumImage:(ShortListAlbum *)slAlbum {
    NSData * imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:slAlbum.albumArtWork]];

    return @{kShortListAlbumArtKey:[UIImage imageWithData: imageData], kShortListAlbumRankKey:@(slAlbum.shortListRank)};
}

- (UIImage *)buildTheImage:(NSArray *)coverArtArray {
    __block NSUInteger rowCount = [self calculateNumberOfRows:coverArtArray.count];
    CGSize imageSize = CGSizeMake(kShortListAlbumArtWorkSize/rowCount, kShortListAlbumArtWorkSize/rowCount);
    CGSize finalSize = CGSizeMake(kShortListAlbumArtWorkSize, kShortListAlbumArtWorkSize);
    
    UIGraphicsBeginImageContext(finalSize);
    [[UIColor blackColor] set];
    UIRectFill(CGRectMake(0.0, 0.0, kShortListAlbumArtWorkSize, kShortListAlbumArtWorkSize));
    
   __block NSUInteger currentRow = 0;
   __block NSUInteger currentColumn = 0;
    [coverArtArray enumerateObjectsUsingBlock:^(NSDictionary *albumDictionary, NSUInteger idx, BOOL *stop) {

        NSPredicate *filter = [NSPredicate predicateWithFormat:@"(%K == %d)", kShortListAlbumRankKey, idx+1];
        NSDictionary *albumArtDictionary = [coverArtArray filteredArrayUsingPredicate:filter].firstObject;
        
        UIImage *anImage = albumArtDictionary[kShortListAlbumArtKey];
        
        if (rowCount > currentRow) {
            [anImage drawInRect:CGRectMake(imageSize.width * currentRow, imageSize.height * currentColumn, imageSize.width, imageSize.height)];
        }
        else {
            currentRow = 0;
            currentColumn++;
            [anImage drawInRect:CGRectMake(imageSize.width * currentRow, imageSize.height * currentColumn, imageSize.width, imageSize.height)];
        }
        currentRow++;
        if (idx+1 > 16) {
            *stop = YES;
        }
        
    }];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

- (NSUInteger)calculateNumberOfRows:(NSInteger)albumCount {
    if (albumCount <= 9) {
        return 3;
    }
    
    return 4;
}

@end
