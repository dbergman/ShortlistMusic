//
//  SLMoreVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLMoreVC.h"
#import "SLLoginCell.h"
#import <Parse/Parse.h>
#import "UIViewController+SLLoginGate.h"
#import "SLGenericOneButtonCell.h"
#import <Twitter/Twitter.h> 
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "SLStyle.h"

@interface SLMoreVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SLMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"More", nil)];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UITableView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoginCellIdentifier = @"LoginCell";
    static NSString *ContactCellIdentifier = @"ContactCell";
    
    if (indexPath.row == 0) {
        SLLoginCell *loginCell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
        if (loginCell == nil) {
            loginCell = [[SLLoginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginCellIdentifier];
        }
        __weak typeof(self)weakSelf = self;
        [loginCell configLoginButton:([PFUser currentUser]) ?: NO loginButtonAction:^{
            (![PFUser currentUser]) ? [weakSelf showLoginGate] : [PFUser logOutInBackground];
            [loginCell updateButtonWithLoginStatus:([PFUser currentUser])];
        }];

        return loginCell;
    }
    
    SLGenericOneButtonCell *contactMeCell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
    if (contactMeCell == nil) {
        contactMeCell = [[SLGenericOneButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
    }
    
    __weak typeof(self)weakSelf = self;
    [contactMeCell setButtonAction:^{
        [weakSelf contactMeAction];
    }];
    
    return contactMeCell;
}

- (void)contactMeAction {
    __weak typeof(self)weakSelf = self;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Contact Me", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([MFMailComposeViewController canSendMail]) {
        UIAlertAction *email = [UIAlertAction actionWithTitle:NSLocalizedString(@"Email", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
                
                NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.large], NSForegroundColorAttributeName: [UIColor whiteColor]};
                [[mailComposeVC navigationBar] setTitleTextAttributes:barButtonAppearanceDict];
                [[mailComposeVC navigationBar] setBarTintColor:[UIColor blackColor]];
                [[mailComposeVC navigationBar] setTintColor:[UIColor whiteColor]];
            
                [mailComposeVC setToRecipients:@[@"shortlistapp01@gmail.com"]];
                [mailComposeVC setSubject:[NSString stringWithFormat:@"Hey Mr.ShortListMusic: "]];

                [self presentViewController:mailComposeVC animated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                }];
        }];
        
        [alert addAction:email];
    }
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        UIAlertAction *twitter = [UIAlertAction actionWithTitle:NSLocalizedString(@"Twitter", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"Hey @shortlistmusic:"];
            [weakSelf presentViewController:tweetSheet animated:YES completion:nil];
        }];
        
        [alert addAction:twitter];
    }
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];

    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
