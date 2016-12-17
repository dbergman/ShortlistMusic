//
//  SLLoginVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLLoginVC.h"
#import "SLStyle.h"
#import "UIViewController+SLToastBanner.h"
#import <Facebook-iOS-SDK/FacebookSDK/FBRequest.h>
#import <Parse/Parse.h>
#import "shortList-Swift.h"
#import <ParseTwitterUtils.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ShortListCoreDataManager.h"
#import "SLShortlistCoreDataMigrtationController.h"

@interface SLLoginVC () <PFLogInViewControllerDelegate>

@property (nonatomic, copy) SLLoginCompletionBlock completion;
@property (nonatomic, strong) SLShortlistCoreDataMigrtationController *dataMigrtationController;

@end

@implementation SLLoginVC

- (instancetype)initWithCompletion:(SLLoginCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.logInView.logo = [SLLoginVC getTempLogo:self.logInView.logo.frame];
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark PFLogInViewControllerDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:user];
    BOOL linkedWithTwitter = [PFTwitterUtils isLinkedWithUser:user];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL migrated = [userDefaults boolForKey:@"migratedToParse"];
    
    if (user.isNew && !migrated) {
        self.dataMigrtationController = [SLShortlistCoreDataMigrtationController new];
        [self.dataMigrtationController addExistingShortListsToParse:[[ShortListCoreDataManager sharedManager] getAllShortLists]];
    }

    if (linkedWithFacebook || linkedWithTwitter) {
        [self userCheck:user isLoggedIn:YES];
    }
    else {
        if (self.completion) {
            self.completion(user, YES);
        }
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [self sl_showToastForAction:NSLocalizedString(@"Login Failed", nil) message:NSLocalizedString(@"Invalid ID or password.", nil) toastType:SLToastMessageFailure completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userCheck:(PFUser *)pfuser isLoggedIn:(BOOL)isLoggedIn {
    FBRequest *request = [FBRequest requestForMe];
    __weak typeof(self)weakSelf = self;
    __weak typeof(PFUser *)weakUser = pfuser;
    [request startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user,  NSError *error) {
        if (!error) {
            __block NSString *fbId = [user objectForKey:@"id"];
            [SLParseController doesSocialIdExistWithSocialId:fbId checkAction:^(BOOL exists) {
                if (exists) {
                    if (weakSelf.completion) {
                        weakSelf.completion(weakUser, isLoggedIn);
                    }
                }
                else {
                    [weakSelf createUsernameforUser:weakUser socialId:fbId];
                }
            }];
        }
    }];
}

- (void)createUsernameforUser:(PFUser *)user socialId:(NSString *)socialId {
    __weak typeof(self)weakSelf = self;
    SLEntryVC *vc = [[SLEntryVC alloc] initWithUser:user onSuccess:^{
        user[@"socialId"] = socialId;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    } onCancel:^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [PFUser logOut];
        }];
    }];
    
    [self showViewController:vc sender:self];
}

+ (UILabel *)getTempLogo:(CGRect)parseLogoFrame {
    UILabel *logoLabel = [UILabel new];
    logoLabel.frame = parseLogoFrame;
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.textColor = [UIColor sl_Red];
    logoLabel.font = [SLStyle polarisFontWithSize:28.0];
    logoLabel.text = @"ShortList Music";
    
    return logoLabel;
}

@end
