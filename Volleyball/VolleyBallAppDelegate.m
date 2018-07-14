//
//  VolleyBallAppDelegate.m
//  Volleyball
//
//  Created by Frank Bara on 5/4/14.
//  Copyright (c) 2014 BaraLabs. All rights reserved.
//

#import "VolleyBallAppDelegate.h"
#import "GBVersionTracking.h"
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import "Chameleon.h"
#import "VolleyBallIAPHelper.h"
#import <AppbotX/ABX.h>
#import "VolleyBallViewController.h"
#import <UIDeviceIdentifier/UIDeviceHardware.h>
//#import "NRWindow.h"

@implementation VolleyBallAppDelegate {
	
}
//#define IS_IPAD() [UIDHardware platformStringSimple] == "iPad"
#define IS_IPAD() [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    //Enable network diagnostic logs
    //setenv("CFNETWORK_DIAGNOSTICS", "3", 1);
    
    // Override point for customization after application launch.
    //[[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationNone];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Needed to instantiate the version tracking
    [GBVersionTracking track];
    // Needed to register the app as a transaction observer from Apple for IAP's
    //TODO: Add back when IAP's fixed.
    //[VolleyBallIAPHelper sharedInstance];

    // Initialize AppbotX info
    [[ABXApiClient instance]
        setApiKey:@"5b0feb30a4f023f3897789f9b38ab62304ee4790"];

    // Google Analytics setup for the app
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
    [GAI sharedInstance].dispatchInterval = 120;
//TODO: Enable Google Analytics
    id<GAITracker> tracker =[ [GAI sharedInstance] trackerWithTrackingId:@"XX-11111111-1"];
    //    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-53202813-1"];
	  tracker.allowIDFACollection = NO;
    
    if ([GBVersionTracking isFirstLaunchEver]) {
        // Initialize the number of times the user has launched the app
        [defaults setBool:TRUE forKey:@"firstTimeEver"];
        [defaults setInteger:1 forKey:@"launchNumber"];
        
        // Show Google Analytics permission alert
        UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        topWindow.rootViewController = [UIViewController new];
        topWindow.windowLevel = UIWindowLevelAlert + 1;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Analytics Request", nil) message:NSLocalizedString(@"With your permission, usage information will be collected to improve the application. No personal information will be collected and you can opt out at any time from Settings.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *no = [UIAlertAction actionWithTitle:NSLocalizedString(@"Opt out", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [self disableAnalytics];
            topWindow.hidden = YES;
        }];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:NSLocalizedString(@"Opt in", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self enableAnalytics];
            topWindow.hidden = YES;
        }];
        
        [alert addAction:no];
        [alert addAction:yes];
        [topWindow makeKeyAndVisible];
        [topWindow.rootViewController presentViewController:alert animated:TRUE completion:nil];
    } else if ([GBVersionTracking isFirstLaunchForBuild]) {
        // Reset the lauch count for each new build
        [defaults setInteger:0 forKey:@"launchNumber"];
    } else {
        // Not first time ever
        NSInteger num = [defaults integerForKey:@"launchNumber"];
        if (num <= 9) {
            [defaults setBool:FALSE forKey:@"firstTimeEver"];
            // Increment launchNumber until we reach 10
            num = num + 1;
            if (num == 10) {
                // It's ok to show the review prompt
                [defaults setBool:TRUE forKey:@"showPrompt"];
            }
            
        } else {
            // We hit 10 launches so reset the count for the review prompt
            [defaults setBool:FALSE forKey:@"showPrompt"];
            num = 0;
        }
        [defaults setInteger:num forKey:@"launchNumber"];

    }
	
	//Check if analytics are allowed on subsequent starts of the app
	NSString *analyticsSetting = [defaults stringForKey:@"analyticsChoice"];
	if ([analyticsSetting isEqualToString:@"Opt out"]) {
		//Opt out - do not track
		[[GAI sharedInstance] setOptOut:YES];
	} else {
		//Opt in - ok to track
		[[GAI sharedInstance] setOptOut:NO];
	}
    return YES;
}

- (void)enableAnalytics {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Opt in - ok to track
    [[GAI sharedInstance] setOptOut:NO];
    [defaults setObject:@"Opt in" forKey:@"analyticsChoice"];
}

- (void)disableAnalytics {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Opt out - do not track
    [[GAI sharedInstance] setOptOut:YES];
    [defaults setObject:@"Opt out" forKey:@"analyticsChoice"];
}

//- (NRWindow *)window
//{
//    static NRWindow *customWindow = nil;
//
//    if (!customWindow) {
//        customWindow = [[NRWindow alloc] initWithFrame:[[UIScreen mainScreen]
//        bounds]];
//    }
//
//    return customWindow;
//}

#pragma mark - Shortcut Items

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler([self handleShortcutItem:shortcutItem]);
}

- (BOOL)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    UIStoryboard *storyboard;
    UINavigationController *navController = (UINavigationController *) self.window.rootViewController;
    NSString *isiPad = [UIDeviceHardware platformStringSimple];
    if ([isiPad rangeOfString:@"ipad" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        //Main_iPad
        storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    }
    
    //VolleyBallViewController *vb = (VolleyBallViewController *)navController.topViewController;
    VolleyBallViewController *vb = [[VolleyBallViewController alloc] init];
    
    if ([shortcutItem.localizedTitle isEqualToString:@"New Match"]) {
        [vb logShortcutUsed:shortcutItem.localizedTitle];
        [vb matchPressedFromShortcut];
        //[vb startNewMatch];
        return TRUE;
        
    } else if ([shortcutItem.localizedTitle isEqualToString:@"New Set"]) {
        [vb logShortcutUsed:shortcutItem.localizedTitle];
        [vb gamePressedFromShortcut];
        return TRUE;
        
    }
    
    return FALSE;
}

- (void)applicationWillResignActive:(UIApplication*)application
{
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

#pragma clang diagnostic pop

@end
