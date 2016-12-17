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
#import "SLShortlist.h"
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
@property (nonatomic, strong) SLShortlist *shortList;
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
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        SLCreateShortListTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if (cell == nil) {
            cell = [[SLCreateShortListTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier];
        }
        
        [cell configTitle:self.shortList];
        
        [cell setCleanUpSLBlock:^ {
            [weakSelf cleanupCreateShortListView];
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.shortList, NO);
            }
        }];
        
        
        [cell setCreateSLBlock:^{
            weakSelf.shortList = [SLShortlist new];
            weakSelf.shortList.shortListName = weakSelf.shortListName;
            weakSelf.shortList.shortListYear = (weakSelf.shortListYear) ? weakSelf.shortListYear: NSLocalizedString(@"All", nil);
            
            [SLParseController saveShortlistWithNewShortList:weakSelf.shortList completion:^{}];
            
            [weakSelf cleanupCreateShortListView];
            
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.shortList, YES);
            }
        }];
        
        [cell setUpdateSLBlock:^{
            weakSelf.shortList.shortListName = weakSelf.shortListName;
            weakSelf.shortList.shortListYear = (weakSelf.shortListYear) ? weakSelf.shortListYear: NSLocalizedString(@"All", nil);
            
            [weakSelf cleanupCreateShortListView];
            
            [SLParseController saveShortlistWithNewShortList:weakSelf.shortList completion:^{}];
            
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
        
        self.shortListName = self.shortList.shortListName;
        [cell configShortListNameCell:self.shortList];
        [cell setCreateNameAction:^(NSString *shortListName){
            weakSelf.shortListName = shortListName;
            
            if (weakSelf.showingYearPicker) {
                [weakSelf.yearPickerCell hidePickerCell:NO];
                weakSelf.showingYearPicker = NO;
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView endUpdates];
                if ([weakSelf.delegate respondsToSelector:@selector(createShortList:willDisplayPickerWithHeight:)]) {
                    [weakSelf.delegate createShortList:weakSelf willDisplayPickerWithHeight:(kSLCreateShortListCellHeight * 2) - kSLCreateShortListPickerHeight];
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
        weakSelf.shortListYear = shortListYear;
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

- (void)updateShortList:(SLShortlist *)shortList {
    self.shortList = shortList;
}

- (void)newShortList {
    self.shortList = nil;
}

@end
