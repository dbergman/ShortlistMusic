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
#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kShortListAlbumArtWorkSize = 320.0;

@implementation SLAlbumArtImaging

- (UIImage *)buildShortListAlbumArt:(Shortlist *)shortlist {
//    - (UIImage *)mergeImagesFromArray: (NSArray *)imageArray {
//        
//        if ([imageArray count] == 0) return nil;
//        
//        UIImage *exampleImage = [imageArray firstObject];
//        CGSize imageSize = exampleImage.size;
//        CGSize finalSize = CGSizeMake(imageSize.width, imageSize.height * [imageArray count]);
//        
//        UIGraphicsBeginImageContext(finalSize);
//        
//        for (UIImage *image in imageArray) {
//            [image drawInRect: CGRectMake(0, imageSize.height * [imageArray indexOfObject: image],
//                                          imageSize.width, imageSize.height)];
//        }
//        
//        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
//        
//        UIGraphicsEndImageContext();
//        
//        return finalImage;
//    }
//
    

            UIImage *shortListAlbumArtWork = [UIImage new];
            
            CGSize shortListAlbumArtWorkSize = CGSizeMake(kShortListAlbumArtWorkSize, kShortListAlbumArtWorkSize);

    
   // ShortListAlbum *slAlbum = shortlist.shortListAlbums.firstObject;
    

    UIGraphicsBeginImageContext(shortListAlbumArtWorkSize);
    
//    CGFloat albumSize = [self calculateAlbumSize:shortlist.shortListAlbums.count];
//   __block UIImageView *albumArtImageView;
//    
//    [shortlist.shortListAlbums enumerateObjectsUsingBlock:^(ShortListAlbum *slAlbum, NSUInteger idx, BOOL *stop) {
//        albumArtImageView = [UIImageView new];
//        
//        [albumArtImageView sd_setImageWithURL:[NSURL URLWithString:slAlbum.albumArtWork]];
//        
//        
//            [shortListAlbumArtWork drawInRect: CGRectMake(0, albumSize.height * [imageArray indexOfObject: image],
//                                                  imageSize.width, imageSize.height)];
//    }];
    
//    for (ShortListAlbum *slAlbum in shortlist.shortListAlbums) {
//        
//    }
    
    
    
//    //slAlbum.albumArtWork
//    
//    UIImageView *albumArtImageView = [UIImageView new];
//   // NSString *artURL = [slAlbum.albumArtWork stringByReplacingOccurrencesOfString:@"400x400-75.jpg" withString:@"1200x1200-75.jpg"];
//    
//    
//    [albumArtImageView sd_setImageWithURL:[NSURL URLWithString:slAlbum.albumArtWork]];
//    
    return shortListAlbumArtWork;
}

- (NSArray *)buildAlbumArtImageArray:(NSArray *)shortListAlbums {
    

    NSMutableArray *albumArtArray = [NSMutableArray new];
    
        for (ShortListAlbum *slAlbum in shortListAlbums) {
            UIImageView *albumArtImageView = [UIImageView new];
            [albumArtImageView sd_setImageWithURL:[NSURL URLWithString:slAlbum.albumArtWork] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [albumArtArray addObject:image];
            }];
        }
    

    
    return [NSArray arrayWithArray:albumArtArray];
}

- (UIImage *)getImage:(NSArray *)imageArray {
    
    return imageArray.firstObject;
}

- (CGFloat)calculateAlbumSize:(NSInteger)albumCount {
    if (albumCount >= 16) {
        return 20;
    }
    
    return kShortListAlbumArtWorkSize/albumCount;
}

@end
