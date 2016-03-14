//
//  VolleyBallAppDelegate.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "VolleyBallAppDelegate.h"
#import <GBVersionTracking/GBVersionTracking.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <ChameleonFramework/Chameleon.h>
#import "VolleyBallIAPHelper.h"
#import <AppbotX/ABX.h>
#import <LaunchKit/LaunchKit.h>
//#import "NRWindow.h"

@implementation VolleyBallAppDelegate {
	NSString *randomUserString;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    // Override point for customization after application launch.
	//[[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationNone];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Needed to instantiate the version tracking
    [GBVersionTracking track];
    // Needed to register the app as a transaction observer from Apple for IAP's
    //[VolleyBallIAPHelper sharedInstance];
    
    [[UINavigationBar appearance] setBarTintColor:FlatBlue];
    [[UINavigationBar appearance] setTintColor:ContrastColor(FlatBlue, TRUE)];
    [[UINavigationBar appearance]
        setTitleTextAttributes:
            @{ NSForegroundColorAttributeName : ContrastColor(FlatBlue, TRUE) }];

    // Initialize AppbotX info
    [[ABXApiClient instance]
        setApiKey:@"5b0feb30a4f023f3897789f9b38ab62304ee4790"];
	
	//Initialize LaunchKit info
//TODO: Enable LaunchKit
//	[LaunchKit launchWithToken:@"6Ms7MJIwN142MdBpvohTgVUCflw4yYEGPn-VOkZHkmO1"];

    // Google Analytics setup for the app
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
    [GAI sharedInstance].dispatchInterval = 120;
//TODO: Enable Google Tracker
    id<GAITracker> tracker =[ [GAI sharedInstance] trackerWithTrackingId:@"XX-11111111-1"];
//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-53202813-1"];
	tracker.allowIDFACollection = NO;
	
	if ([GBVersionTracking isFirstLaunchEver]) {
		randomUserString = [self randomStringWithLength:8];
		[defaults setObject:randomUserString forKey:@"userString"];
	} else {
		randomUserString = [defaults objectForKey:@"userString"];
		if (randomUserString == nil) {
			randomUserString = [self randomStringWithLength:8];
			[defaults setObject:randomUserString forKey:@"userString"];
		}
	}

    if ([GBVersionTracking isFirstLaunchEver] || [GBVersionTracking isFirstLaunchForVersion]) {
        // Initialize the number of times the user has launched the app
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"launchNumber"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes"
                                                  forKey:@"showPrompt"];

        // Show Google Analytics permissiion alert
        UIAlertView* av = [[UIAlertView alloc]
                initWithTitle:@"Analytics Request"
                      message:@"With your permission, usage information will be "
                      @"collected to improve the application.\n\nNo "
                      @"personal information will be collected and you "
                      @"can opt out at any time from Settings."
                     delegate:self
            cancelButtonTitle:@"Opt Out"
            otherButtonTitles:@"Opt In", nil];
        [av show];
    } else if (([[NSUserDefaults standardUserDefaults] integerForKey:@"launchNumber"]) < 5) {
        // Increment launchNumber until we reach 5
        NSInteger ln =
            [[NSUserDefaults standardUserDefaults] integerForKey:@"launchNumber"];
        ln = ln + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:ln
                                                   forKey:@"launchNumber"];

    } else {
        // We hit 5 uses so turn off the review prompt
        [[NSUserDefaults standardUserDefaults] setObject:@"No"
                                                  forKey:@"showPrompt"];

    }
	
	//Check if user is allowing analytics or not
	//We hit 5 uses so turn off the review prompt
	[[NSUserDefaults standardUserDefaults] setObject:@"No"
											  forKey:@"showPrompt"];
	//Check if analytics are allowed on subsequent starts of the app
	NSString *analyticsSetting = [[NSUserDefaults standardUserDefaults] stringForKey:@"analyticsChoice"];
	if ([analyticsSetting isEqualToString:@"Opt out"]) {
		//Opt out - do not track
		[[GAI sharedInstance] setOptOut:YES];
	} else {
		//Opt in - ok to track
		[[GAI sharedInstance] setOptOut:NO];
//TODO: Enable LaunchKit
//		[[LaunchKit sharedInstance] setUserIdentifier:randomUserString email:[randomUserString stringByAppendingString:@"@email.com"] name:randomUserString];
//        if (LKAppUserIsSuper()) {
//            //SuperUser
//            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//            [tracker send:[[[GAIDictionaryBuilder createScreenView] set:@"Super User" forKey:kGAIScreenName] build]];
//
//        }
	}
	
    [[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//Get response from user if they allow analytics on initial startup
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    switch (buttonIndex) {
    case 0:
		//Opt out - do not track
        [[GAI sharedInstance] setOptOut:YES];
        [defaults setObject:@"Opt out" forKey:@"analyticsChoice"];
        break;
    case 1:
		//Opt out - do not track	
        [[GAI sharedInstance] setOptOut:NO];
        [defaults setObject:@"Opt in" forKey:@"analyticsChoice"];
//TODO: Enable LaunchKit
//		[[LaunchKit sharedInstance] setUserIdentifier:randomUserString email:[randomUserString stringByAppendingString:@"@email.com"] name:randomUserString];

        break;
    default:
        break;
    }
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


-(NSString *) randomStringWithLength: (int) len {
	NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	
	NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
	for (int i=0; i<len; i++) {
		[randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
	}
	
	return randomString;
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
