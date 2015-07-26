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
#import "SLStyle.h"

static const CGFloat kSLAlbumCellSize = 120;

@interface SLAlbumsCollectionCell () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) Shortlist *shortlist;
@property (nonatomic, strong) UIView *shortlistDetailsView;
@property (nonatomic, strong) UILabel *shortlistNamelabel;
@property (nonatomic, strong) UILabel *shortlistYearlabel;

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
        
        self.shortlistDetailsView = [UIView new];
        self.shortlistDetailsView.translatesAutoresizingMaskIntoConstraints = NO;
        self.shortlistDetailsView.backgroundColor = [UIColor blackColor];
        self.shortlistDetailsView.alpha = .7;
        [self.contentView addSubview:self.shortlistDetailsView];
        
        self.shortlistNamelabel = [UILabel new];
        self.shortlistNamelabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.shortlistNamelabel.font = [UIFont fontWithName:self.shortlistNamelabel.font.fontName size:FontSizes.large];
        self.shortlistNamelabel.textColor = [UIColor whiteColor];
        self.shortlistNamelabel.preferredMaxLayoutWidth = self.contentView.frame.size.width/2.0;
        [self.shortlistDetailsView addSubview:self.shortlistNamelabel];
        
        self.shortlistYearlabel = [UILabel new];
        self.shortlistYearlabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.shortlistYearlabel.font = [UIFont fontWithName:self.shortlistNamelabel.font.fontName size:FontSizes.large];
        self.shortlistYearlabel.textColor = [UIColor whiteColor];
        self.shortlistYearlabel.preferredMaxLayoutWidth = self.contentView.frame.size.width/2.0;
        [self.shortlistDetailsView addSubview:self.shortlistYearlabel];

        NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView, _shortlistDetailsView, _shortlistNamelabel, _shortlistYearlabel);
        NSDictionary *metrics = @{@"collectionViewHeight":@(kSLAlbumCellSize), @"shortlistDetailsViewHeight":@(30)};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView(collectionViewHeight)]|" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shortlistDetailsView]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_shortlistDetailsView(shortlistDetailsViewHeight)]|" options:0 metrics:metrics views:views]];
        
        [self.shortlistDetailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_shortlistNamelabel]" options:0 metrics:metrics views:views]];
        [self.shortlistDetailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_shortlistNamelabel]-|" options:0 metrics:metrics views:views]];
        
        [self.shortlistDetailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_shortlistYearlabel]-|" options:0 metrics:metrics views:views]];
        [self.shortlistDetailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_shortlistYearlabel]-|" options:0 metrics:metrics views:views]];
    }
    
    return self;
}

- (void)configShortListCollection:(Shortlist *)shortList {
    self.shortlist = shortList;
    self.shortlistNamelabel.text = [shortList.shortListName uppercaseString];
    self.shortlistYearlabel.text = shortList.shortListYear;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shortlist.shortListAlbums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    [cell configWithShortListAlbum:self.shortlist.shortListAlbums[indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kSLAlbumCellSize, kSLAlbumCellSize);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView animateWithDuration:.2 animations:^{
        self.shortlistDetailsView.alpha = 0.0;
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [UIView animateWithDuration:.2 animations:^{
        self.shortlistDetailsView.alpha = 0.0;
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [UIView animateWithDuration:.2 animations:^{
        self.shortlistDetailsView.alpha = 0.7;
    }];
}

@end
