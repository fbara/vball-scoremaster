//
//  VolleyBallAppDelegate.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "VolleyBallAppDelegate.h"
#import "GBVersionTracking.h"


@implementation VolleyBallAppDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [GBVersionTracking track];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    
    //Google Analytics setup for the app
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
    [GAI sharedInstance].dispatchInterval = 120;
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-53202813-1"];
    
    if ([GBVersionTracking isFirstLaunchEver] || [GBVersionTracking isFirstLaunchForVersion]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Google Analytics" message:@"With your permission usage information will be collected to improve the application.\n\nNo personal information will be collected and you can opt out at any time from Settings." delegate:self cancelButtonTitle:@"Opt Out" otherButtonTitles:@"Opt In", nil];
        [av show];
    }
    
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (buttonIndex) {
        case 0:
            [[GAI sharedInstance] setOptOut:YES];
            [defaults setObject:@"Opt out" forKey:@"analyticsChoice"];
            break;
        case 1:
            [[GAI sharedInstance] setOptOut:NO];
            [defaults setObject:@"Opt in" forKey:@"analyticsChoice"];
            break;
        default:
            break;
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma clang diagnostic pop

@end
