//
//  SLCreateShortListVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLCreateShortListVC.h"
#import "SLCreateShortListTitleCell.h"
#import "SLCreateShortListButtonCell.h"

@interface SLCreateShortListVC ()

@end

@implementation SLCreateShortListVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor yellowColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.tableView.bounds;
    frame.origin.y = 0.0;
    self.tableView.bounds = frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"");
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TitleCellIdentifier = @"TitleCell";
    static NSString *ButtonCellIdentifier = @"ButtonCell";
    
    if (indexPath.row == 0) {
        SLCreateShortListTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
        if (cell == nil) {
            cell = [[SLCreateShortListTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TitleCellIdentifier];
        }
        
        return cell;
    }

    SLCreateShortListButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
    if (cell == nil) {
        cell = [[SLCreateShortListButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonCellIdentifier];
    }
    [cell setCancelBlock:^ {
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

@end
