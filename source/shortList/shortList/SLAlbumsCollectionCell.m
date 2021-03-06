//
//  SLAlbumsCell.m
//  shortList
//
//  Created by Dustin Bergman on 7/15/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumsCollectionCell.h"
#import "SLShortlist.h"
#import "SLAlbumCell.h"
#import "SLStyle.h"

static const CGFloat kSLAlbumCellSize = 120;

@interface SLAlbumsCollectionCell () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) SLShortlist *shortlist;
@property (nonatomic, strong) UIView *shortlistDetailsView;
@property (nonatomic, strong) UILabel *shortlistNamelabel;
@property (nonatomic, strong) UILabel *shortlistYearlabel;

@end

@implementation SLAlbumsCollectionCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.shouldIndentWhileEditing = NO;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView registerClass:[SLAlbumCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [self.contentView addSubview:self.collectionView];
        
        self.shortlistDetailsView = [UIView new];
        self.shortlistDetailsView.backgroundColor = [UIColor blackColor];
        self.shortlistDetailsView.alpha = .7;
        [self.contentView addSubview:self.shortlistDetailsView];
        
        self.shortlistNamelabel = [UILabel new];
        self.shortlistNamelabel.font = [SLStyle polarisFontWithSize:FontSizes.large];
        self.shortlistNamelabel.textColor = [UIColor whiteColor];
        self.shortlistNamelabel.preferredMaxLayoutWidth = self.contentView.frame.size.width/2.0;
        [self.shortlistDetailsView addSubview:self.shortlistNamelabel];
        
        self.shortlistYearlabel = [UILabel new];
        self.shortlistYearlabel.font = [SLStyle polarisFontWithSize:FontSizes.large];
        self.shortlistYearlabel.textColor = [UIColor whiteColor];
        self.shortlistYearlabel.preferredMaxLayoutWidth = self.contentView.frame.size.width/2.0;
        [self.shortlistDetailsView addSubview:self.shortlistYearlabel];
        
        for (UIView *view in @[self.collectionView, self.shortlistDetailsView, self.shortlistNamelabel, self.shortlistYearlabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }

        NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView, _shortlistDetailsView, _shortlistNamelabel, _shortlistYearlabel);
        NSDictionary *metrics = @{@"collectionViewHeight":@(kSLAlbumCellSize), @"shortlistDetailsViewHeight":@(40)};
        
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

- (void)configShortListCollection:(SLShortlist *)shortList {
    self.shortlist = shortList;
    self.shortlistNamelabel.text = [shortList.shortListName uppercaseString];
    self.shortlistYearlabel.text = shortList.shortListYear;
    
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    self.shortlistDetailsView.alpha = 0.7;
}


#pragma mark UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shortlist.shortListAlbums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    [cell configWithShortListAlbum:self.shortlist.shortListAlbums[indexPath.row]];
    
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kSLAlbumCellSize, kSLAlbumCellSize);
}

#pragma mark UIScrollViewDelegate
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
