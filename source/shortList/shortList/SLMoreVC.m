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
#import "UIViewController+SLToastBanner.h"
#import "shortlist-Swift.h"

@interface SLMoreVC () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

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
    return 3;
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
    
    else if (indexPath.row == 1) {
        SLGenericOneButtonCell *forgetPasswordCell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
        if (forgetPasswordCell == nil) {
            forgetPasswordCell = [[SLGenericOneButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
        }
        
        [forgetPasswordCell.oneButton setTitle:NSLocalizedString(@"Forgot or Reset Password", nil) forState:UIControlStateNormal];
        [forgetPasswordCell.oneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        forgetPasswordCell.oneButton.titleLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        forgetPasswordCell.oneButton.backgroundColor = [UIColor sl_yellow];
        
        __weak typeof(self)weakSelf = self;
        [forgetPasswordCell setButtonAction:^{
            [weakSelf resetUserPasswordAlert];
        }];
        
        return forgetPasswordCell;
    }
    
    SLGenericOneButtonCell *contactMeCell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
    if (contactMeCell == nil) {
        contactMeCell = [[SLGenericOneButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
    }
    
    [contactMeCell.oneButton setTitle:NSLocalizedString(@"Contact Me", nil) forState:UIControlStateNormal];
    [contactMeCell.oneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    contactMeCell.oneButton.titleLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
    contactMeCell.oneButton.backgroundColor = [UIColor grayColor];
    
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
                mailComposeVC.mailComposeDelegate = self;
                
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

- (void)resetUserPasswordAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Reset password",nil)  message:NSLocalizedString(@"Enter Email Address:",nil) preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            [weakSelf emailValidation:alert.textFields.firstObject.text];
                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Email Address", nil);
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)emailValidation:(NSString *)email {
    __weak typeof(self)weakself = self;
    
    if ([weakself isValidEmailAddress:email]) {
        [SLParseController doesUserEmailExist:email.lowercaseString checkAction:^(BOOL exists) {
            if (exists) {
                [SLParseController resetPassword:email successAction:^{
                    [weakself sl_showToastForAction:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Please check your email for reset password link", nil) toastType:SLToastMessageSuccess completion:nil];
                } failureAction:^{
                    [weakself sl_standardToastUnableToCompleteRequest];
                }];
            }
            else {
                [weakself sl_showToastForAction:NSLocalizedString(@"Failure", nil) message:NSLocalizedString(@"Email not found.", nil) toastType:SLToastMessageFailure completion:nil];
            }
        }];
    }
    else {
        [weakself sl_showToastForAction:NSLocalizedString(@"Invalid", nil) message:NSLocalizedString(@"Invalid Email.", nil) toastType:SLToastMessageFailure completion:nil];
    }
}

#pragma maek MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    dispatch_block_t toastAction = ^{};
    if (error) {
        toastAction = ^{
            [self sl_showToastForAction:NSLocalizedString(@"Error Sending Email", nil) message:error.description toastType:SLToastMessageFailure completion:nil];
        };
    }
    else if (result == MFMailComposeResultSent) {
        toastAction = ^{
            [self sl_showToastForAction:NSLocalizedString(@"Sent ShortList Email", nil) message:nil toastType:SLToastMessageSuccess completion:nil];
        };
    }
    else if (result == MFMailComposeResultFailed) {
        toastAction = ^{
            [self sl_showToastForAction:NSLocalizedString(@"Failed Sending Email", nil) message:nil toastType:SLToastMessageFailure completion:nil];
        };
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        if (toastAction) {
            toastAction();
        }
    }];
}

- (BOOL)isValidEmailAddress:(NSString *)emailAddress {
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" ;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];

    return [emailTest evaluateWithObject:emailAddress];
}

@end
