//
//  UIViewController+SLAlbumArtImaging.m
//  shortList
//
//  Created by Dustin Bergman on 8/16/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLAlbumArtImaging.h"
#import "UIViewController+Utilities.h"
#import "NSObject+BKAssociatedObjects.h"
#import "Shortlist.h"
#import "SLAlbumCell.h"

@interface UIViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@end

@implementation UIViewController (SLAlbumArtImaging)

- (void)buildShortlistAlbumArtImage {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, [self getScreenHeight], [self getScreenWidth], [self getScreenWidth]) collectionViewLayout:layout];
    collectionView.scrollEnabled = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[SLAlbumCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:collectionView];
    
    [self saveCollectionView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self shortlist].shortListAlbums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    [cell configWithShortListAlbum:[self shortlist].shortListAlbums[indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake([self getScreenWidth]/4, [self getScreenWidth]/4);
}

- (void)loadCollectionViewImage:(Shortlist *)shortlist {
    [self saveShortList:shortlist];
    
    [[self collectionView] reloadData];
}

- (void)saveShortList:(Shortlist *)shortlist {
    [self bk_associateValue:shortlist withKey:@"shortlist"];
}

- (Shortlist *)shortlist {
    return [self bk_associatedValueForKey:@"shortlist"];
}

- (void)saveCollectionView:(UICollectionView *)collectionView {
    [self bk_associateValue:collectionView withKey:@"collectionView"];
}

- (UICollectionView *)collectionView {
    return [self bk_associatedValueForKey:@"collectionView"];
}

- (UIImage *)getAlbumArtCollectionImage {
    UIGraphicsBeginImageContext(CGSizeMake(375, 375));
    [[[self collectionView] layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenshot;
}


@end
