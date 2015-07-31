//
//  SLCreateShortListVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLCreateShortListVC.h"
#import "SLStyle.h"
#import "SLCreateShortListTitleCell.h"
#import "SLCreateShortListEnterNameCell.h"
#import "SLCreateShortListEnterYearCell.h"
#import "Shortlist.h"
#import <QuartzCore/QuartzCore.h>
#import "shortList-Swift.h"

CGFloat const kSLCreateShortListPickerHeight = 180.0;
CGFloat const kSLCreateShortListCellHeight = 44.0;
NSInteger const kSLCreateShortListCellCount = 3;

@interface SLCreateShortListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL showingYearPicker;
@property (nonatomic, strong) SLCreateShortListEnterYearCell *yearPickerCell;
@property (nonatomic, strong) SLCreateShortListEnterNameCell *shortListNameCell;
@property (nonatomic, strong) NSString *shortListName;
@property (nonatomic, strong) NSString *shortListYear;
@property (nonatomic, strong) Shortlist *shortList;
@property (nonatomic, copy) SLCreateUpdateShortListCompletion completion;

@end

@implementation SLCreateShortListVC

- (instancetype)initWithCompletion:(SLCreateUpdateShortListCompletion)completion {
    self = [super init];
    
    if (self) {
        self.completion = completion;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor sl_Red];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.scrollEnabled = NO;
    [self.tableView setAutoresizesSubviews:YES];
    [self.tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];

    [self.view addSubview:self.tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kSLCreateShortListCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TitleCellIdentifier = @"TitleCell";
    static NSString *NameCellIdentifier = @"NameCell";
    static NSString *YearCellIdentifier = @"YearCell";
    
    __weak typeof(self) weakself = self;
    if (indexPath.row == 0) {
        SLCreateShortListTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if (cell == nil) {
            cell = [[SLCreateShortListTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier];
        }
        
        [cell configTitle:self.shortList];
        
        __weak typeof(self) weakSelf = self;
        [cell setCleanUpSLBlock:^ {
            [weakSelf cleanupCreateShortListView];
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.shortList, NO);
            }
        }];
        
        [cell setCreateSLBlock:^{
            Shortlist *shortList = [Shortlist new];
            shortList.shortListName = weakSelf.shortListName;
            shortList.shortListYear = (weakSelf.shortListYear) ? weakSelf.shortListYear: NSLocalizedString(@"All", nil);
            
           weakSelf.shortList = [SLParseController saveShortlist:shortList];
            
            [weakSelf cleanupCreateShortListView];
            
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.shortList, YES);
            }
        }];
        
        [cell setUpdateSLBlock:^{
            weakSelf.shortList.shortListName = weakSelf.shortListName;
            weakSelf.shortList.shortListYear = (weakSelf.shortListYear) ? weakSelf.shortListYear: NSLocalizedString(@"All", nil);
            
            [weakSelf cleanupCreateShortListView];
            
            weakSelf.shortList = [SLParseController saveShortlist:weakSelf.shortList];
            
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.shortList, NO);
            }
        }];
        
        
        return cell;
    }
    else if (indexPath.row == 1) {
        SLCreateShortListEnterNameCell *cell = [tableView dequeueReusableCellWithIdentifier:NameCellIdentifier];
        if (cell == nil) {
            cell = [[SLCreateShortListEnterNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NameCellIdentifier];
        }
        
        [cell configShortListNameCell:self.shortList];
        [cell setCreateNameAction:^(NSString *shortListName){
            weakself.shortListName = shortListName;
            
            if (weakself.showingYearPicker) {
                [weakself.yearPickerCell hidePickerCell:NO];
                weakself.showingYearPicker = NO;
                [weakself.tableView beginUpdates];
                [weakself.tableView endUpdates];
                if ([weakself.delegate respondsToSelector:@selector(createShortList:willDisplayPickerWithHeight:)]) {
                    [weakself.delegate createShortList:weakself willDisplayPickerWithHeight:(kSLCreateShortListCellHeight * 2) - kSLCreateShortListPickerHeight];
                }
            }
        }];
        self.shortListNameCell = cell;
        return cell;
    }

    SLCreateShortListEnterYearCell *cell = [tableView dequeueReusableCellWithIdentifier:YearCellIdentifier];
    if (cell == nil) {
        cell = [[SLCreateShortListEnterYearCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:YearCellIdentifier];
    }
    self.yearPickerCell = cell;
    [cell configYearCell:self.shortList];
    
    [cell setCreateYearAction:^(NSString *shortListYear){
        weakself.shortListYear = shortListYear;
    }];
    return cell;
}

- (void)cleanupCreateShortListView {
    self.showingYearPicker = NO;
    [self.yearPickerCell hidePickerCell:YES];
    [self.shortListNameCell clearShortListName];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2 && !self.showingYearPicker) {
        self.showingYearPicker = YES;
        [self.view endEditing:YES];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        if ([self.delegate respondsToSelector:@selector(createShortList:willDisplayPickerWithHeight:)]) {
            [self.delegate createShortList:self willDisplayPickerWithHeight:kSLCreateShortListPickerHeight];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        if (self.showingYearPicker) {
             return kSLCreateShortListPickerHeight;
        }
    }
    
    return kSLCreateShortListCellHeight;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)updateShortList:(ShortList *)shortList {
    self.shortList = shortList;
}

- (void)newShortList {
    self.shortList = nil;
}

@end
