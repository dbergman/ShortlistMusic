//
//  AppDelegate.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "AppDelegate.h"
#import "SLNavigationController.h"
#import "SLTabBarController.h"
#import "SLFeedVC.h"
#import "SLListsVC.h"
#import "SLProfileVC.h"
#import "SLMoreVC.h"
#import "SLStyle.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SLShortlist.h"
#import "SLShortListAlbum.h"
#import "SLStyle.h"
#import <Parse/PFTwitterUtils.h>
#import <Parse/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "Flurry.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

static NSString *const kFlurryAnalyticsKey = @"3QHC8HXPGJF7Q6D2JTD7";

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [self setupThirdPartyLibraries];
    [self turnOnNSURLCache];
    [self setupAppearance];
    
    self.window.rootViewController = [self shortListTabController];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                        openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                        annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    return handled;
}

- (void)applicationWillTerminate:(UIApplication *)application {}

- (UIViewController *)shortListTabController {
    SLFeedVC *slFeedVC = [SLFeedVC new];
    SLNavigationController *shortListFeedNav = [[SLNavigationController alloc] initWithRootViewController:slFeedVC];
    shortListFeedNav.tabBarItem.title = NSLocalizedString(@"Feed", nil);

    SLListsVC *slListsVC = [SLListsVC new];
    SLNavigationController *shortListsNav = [[SLNavigationController alloc] initWithRootViewController:slListsVC];
    shortListsNav.tabBarItem.title = NSLocalizedString(@"ShortLists", nil);
    shortListsNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"myShortLists"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    shortListsNav.tabBarItem.image = [[UIImage imageNamed:@"myShortLists"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    SLProfileVC *slProfileVC = [SLProfileVC new];
    SLNavigationController *shortListProfileNav = [[SLNavigationController alloc] initWithRootViewController:slProfileVC];
    shortListProfileNav.tabBarItem.title = NSLocalizedString(@"Profile", nil);
    
    SLMoreVC *slMoreVC = [SLMoreVC new];
    SLNavigationController *shortListMoreNav = [[SLNavigationController alloc] initWithRootViewController:slMoreVC];
    shortListMoreNav.tabBarItem.title = NSLocalizedString(@"More", nil);
    shortListMoreNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"moreTab"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    shortListMoreNav.tabBarItem.image = [[UIImage imageNamed:@"moreTab"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    SLTabBarController *tabBarController = [SLTabBarController new];
    //[tabBarController setViewControllers:@[shortListFeedNav, shortListsNav, shortListProfileNav, shortListMoreNav]];
    [tabBarController setViewControllers:@[shortListsNav, shortListMoreNav]];
    tabBarController.tabBar.backgroundColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;

    tabBarController.selectedViewController=[tabBarController.viewControllers objectAtIndex:0];

    return tabBarController;
}

- (void)setUpParseForProd:(BOOL)isProd {
    NSDictionary *appKeyDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"appKeys" ofType:@"plist"]];
    NSAssert(appKeyDictionary, @"You Must Add /opt/shortList/appKeys to your local File System!!!");

    NSDictionary *envDictionary = (isProd) ? appKeyDictionary[@"ShortListMusicProd"] : appKeyDictionary[@"ShortListMusicDev"];

    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = envDictionary[@"ParseAppId"];
        configuration.clientKey = envDictionary[@"ParseClientKey"];
        configuration.server = @"https://parseapi.back4app.com";
    }]];
    
    [SLShortlist registerSubclass];
    [SLShortListAlbum registerSubclass];
}

- (void)setupAppearance {
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:YES];

    [[UITabBar appearance] setTintColor:[UIColor sl_Red]];
    
    [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.xSmall]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor sl_Red], NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.xSmall]} forState:UIControlStateSelected];
    
    NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.medium] , NSForegroundColorAttributeName: [UIColor whiteColor]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
}

- (void)turnOnNSURLCache {
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024  diskCapacity:100 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

- (void)setupThirdPartyLibraries {
#ifdef DEBUG
    [self setUpParseForProd:NO];
#elif APPSTORE
    [Flurry startSession:kFlurryAnalyticsKey];
    [self setUpParseForProd:YES];
#endif 
}

@end
