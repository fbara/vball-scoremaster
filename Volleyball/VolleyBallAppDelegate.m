//
//  VolleyBallAppDelegate.m
//  Volleyball
//
//  Created by Frank Bara on 5/4/14.
//  Copyright (c) 2014 BaraLabs. All rights reserved.
//

#import "VolleyBallAppDelegate.h"
#import "GBVersionTracking.h"
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
    
    if ([GBVersionTracking isFirstLaunchEver]) {
        // Initialize the number of times the user has launched the app
        [defaults setBool:TRUE forKey:@"firstTimeEver"];
        [defaults setInteger:1 forKey:@"launchNumber"];
        
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
	
    return YES;
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
        [vb matchPressedFromShortcut];
        //[vb startNewMatch];
        return TRUE;
        
    } else if ([shortcutItem.localizedTitle isEqualToString:@"New Set"]) {
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
