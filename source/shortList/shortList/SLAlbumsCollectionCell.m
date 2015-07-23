//
//  SLAlbumsCell.m
//  shortList
//
//  Created by Dustin Bergman on 7/15/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumsCollectionCell.h"
#import "Shortlist.h"
#import "SLAlbumCell.h"

@interface SLAlbumsCollectionCell () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) Shortlist *shortlist;

@end

@implementation SLAlbumsCollectionCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView registerClass:[SLAlbumCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [self.contentView addSubview:self.collectionView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView);
        NSDictionary *metrics = @{};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView(120)]|" options:0 metrics:metrics views:views]];
    }
    
    return self;
}

- (void)configShortListCollection:(Shortlist *)shortList {
    self.shortlist = shortList;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shortlist.shortListAlbums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    [cell configWithShortListAlbum:self.shortlist.shortListAlbums[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(120, 120);
}

@end
