//
//  SLAlbumArtImaging.m
//  shortList
//
//  Created by Dustin Bergman on 8/18/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumArtImaging.h"
#import "SLShortlist.h"
#import "SLShortListAlbum.h"
#import "SLStyle.h"

static NSString * const kShortListAlbumArtKey = @"slAlbumImage";
static NSString * const kShortListAlbumRankKey = @"slAlbumRank";
static const CGFloat kShortListAlbumArtWorkSize = 320.0;

@interface SLAlbumArtImaging ()

@property (nonatomic, strong) SLShortlist *shortList;

@end

@implementation SLAlbumArtImaging

- (UIImage *)buildShortListAlbumArt:(SLShortlist *)shortlist {
    self.shortList = shortlist;
    NSOperationQueue *queue = [NSOperationQueue new];
    NSMutableArray *operationArray = [NSMutableArray new];
    
    NSMutableArray *albumArtArray = [NSMutableArray new];
    
    __weak typeof(self)weakSelf = self;
    for (SLShortListAlbum *slAlbum in shortlist.shortListAlbums) {
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

- (NSDictionary *)downloadAlbumImage:(SLShortListAlbum *)slAlbum {
   NSURL *albumArtUrl = [NSURL URLWithString:[slAlbum.albumArtWork stringByReplacingOccurrencesOfString:@"400" withString:@"1200"]];
   NSData *imageData = [[NSData alloc] initWithContentsOfURL:albumArtUrl];
    
    // Image is not available.
    if (!imageData) {
        return @{kShortListAlbumArtKey:[UIImage imageNamed:@"albumPlaceHolder"], kShortListAlbumRankKey:@(slAlbum.shortListRank)};
    }

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
    
    finalImage = [self drawWatermark:[NSString stringWithFormat:@"%@ \n %@", self.shortList.shortListName, @"#shortListMusic"] inImage:finalImage];
    
    return finalImage;
}

- (UIImage*)drawWatermark:(NSString*)watermarkText inImage:(UIImage*)image {
    NSDictionary *attributeDictionary = @{NSFontAttributeName: [SLStyle polarisFontWithSize:FontSizes.medium], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    [[[UIColor blackColor] colorWithAlphaComponent:.5] set];
    
    CGSize watermarkSize = [watermarkText sizeWithAttributes:attributeDictionary];
    CGRect watermarkRect = CGRectMake(0.0, (image.size.height - watermarkSize.height), image.size.width, image.size.height);

    CGContextFillRect(UIGraphicsGetCurrentContext(), watermarkRect);
    
    [watermarkText drawInRect:watermarkRect withAttributes:attributeDictionary];

    UIImage *watermarkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return watermarkedImage;
}

- (NSUInteger)calculateNumberOfRows:(NSInteger)albumCount {
    if (albumCount <= 9) {
        return 3;
    }
    
    return 4;
}

@end
