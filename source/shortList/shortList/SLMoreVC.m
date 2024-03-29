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
#import "UIViewController+SLEmailShortlist.h"
#import "shortList-Swift.h"

@interface SLMoreVC () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ExportShortListProvider *exportProvider;

@end

@implementation SLMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"More", nil)];
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogin:) name:PFLogInSuccessNotification object:nil];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UITableView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)userLogin:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([PFUser currentUser]) ? 4 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoginCellIdentifier = @"LoginCell";
    static NSString *GenericOneButtonCell = @"GenericCell";
    
    if (indexPath.row == 0) {
        SLLoginCell *loginCell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
        if (loginCell == nil) {
            loginCell = [[SLLoginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginCellIdentifier];
        }
        __weak typeof(self)weakSelf = self;
        [loginCell configLoginButton:([PFUser currentUser] !=nil) ?: NO loginButtonAction:^{
            if (![PFUser currentUser]) {
                [weakSelf showLoginGate];
            } else {
                [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
                    [weakSelf.tableView reloadData];
                }];
            }

            [loginCell updateButtonWithLoginStatus:([PFUser currentUser] != nil)];
        }];

        return loginCell;
    }
    
    else if (indexPath.row == 1) {
        SLGenericOneButtonCell *forgetPasswordCell = [tableView dequeueReusableCellWithIdentifier:GenericOneButtonCell];
        if (forgetPasswordCell == nil) {
            forgetPasswordCell = [[SLGenericOneButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GenericOneButtonCell];
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
    
    else if ([PFUser currentUser] && indexPath.row == 2) {
        SLGenericOneButtonCell *exportShortListCell = [tableView dequeueReusableCellWithIdentifier:GenericOneButtonCell];
        if (exportShortListCell == nil) {
            exportShortListCell = [[SLGenericOneButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GenericOneButtonCell];
        }
        
        [exportShortListCell.oneButton setTitle:NSLocalizedString(@"Export ShortLists", nil) forState:UIControlStateNormal];
        [exportShortListCell.oneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        exportShortListCell.oneButton.titleLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        exportShortListCell.oneButton.backgroundColor = [UIColor greenColor];
        
        __weak typeof(self)weakSelf = self;
        [exportShortListCell setButtonAction:^{
            weakSelf.exportProvider = [[ExportShortListProvider alloc] initWithVc:self];
            [weakSelf.exportProvider emailShortList];
        }];
        
        return exportShortListCell;
    }
    
    SLGenericOneButtonCell *contactMeCell = [tableView dequeueReusableCellWithIdentifier:GenericOneButtonCell];
    if (contactMeCell == nil) {
        contactMeCell = [[SLGenericOneButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GenericOneButtonCell];
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
            [weakSelf contactMeEmail];
        }];
        
        [alert addAction:email];
    }
    
    UIAlertAction *twitter = [UIAlertAction actionWithTitle:NSLocalizedString(@"Twitter", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        NSURL *appURL = [NSURL URLWithString: @"twitter://user?screen_name=shortlistmusic"];
        NSURL *webURL = [NSURL URLWithString: @"https://twitter.com/shortlistmusic"];

        if ([[UIApplication sharedApplication] canOpenURL: appURL]) {
            [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:webURL options:@{} completionHandler:nil];
        }
    }];
    
    [alert addAction:twitter];

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
        [SLParseController doesUserEmailExistWithEmail:email.lowercaseString checkAction:^(BOOL exists) {
            if (exists) {
                [SLParseController resetPasswordWithEmail:email successAction:^{
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


- (BOOL)isValidEmailAddress:(NSString *)emailAddress {
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" ;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];

    return [emailTest evaluateWithObject:emailAddress];
}

@end
