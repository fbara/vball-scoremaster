//
//  PermissionsViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 11/12/15.
//  Copyright © 2015 BaraLabs, LLC. All rights reserved.
//

#import "PermissionsViewController.h"
#import <ClusterPrePermissions/ClusterPrePermissions.h>
#import <GBVersionTracking/GBVersionTracking.h>
#import <GoogleAnalytics/GAI.h>
#import <AppbotX/ABX.h>
#import <LaunchKit/LaunchKit.h>

enum availablePermission {
	permContact, // == 0
	permLibrary, // == 1
	permLocation // == 2
};

@interface PermissionsViewController ()

@end

@implementation PermissionsViewController {
	NSUserDefaults *defaults;
	NSString *randomUserString, *title, *msg, *denyTitle, *grantTitle;
	ClusterPrePermissions *permissions;

}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	defaults = [NSUserDefaults standardUserDefaults];
	[self setupGoogleAnalytics];
	[self setupLaunchKit];
	[self setupAppbotX];
	

}

- (void)checkForFirstTime {

	if ([GBVersionTracking isFirstLaunchEver] || [GBVersionTracking isFirstLaunchForVersion]) {
		// Initialize the number of times the user has launched the app
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"launchNumber"];
		[[NSUserDefaults standardUserDefaults] setObject:@"Yes"
												  forKey:@"showPrompt"];
		
		
		
	} else if (([[NSUserDefaults standardUserDefaults]
				 integerForKey:@"launchNumber"]) < 5) {
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

}

- (void)showPermissions:(enum availablePermission)appPerm {
	permissions = [ClusterPrePermissions sharedPermissions];
	switch (appPerm) {
		case permContact:
			
			break;
		case permLibrary:
			
			break;
		case permLocation:
			[self requestLocationPermission];
			break;
  default:
			break;
	}
	

}

- (void)requestLocationPermission {
	title = @"Access Your Location?";
	msg = @"The app needs your location when in use.";
	denyTitle = @"No way!";
	grantTitle = @"Absolutely";
	[permissions showLocationPermissionsForAuthorizationType:ClusterLocationAuthorizationTypeWhenInUse
													   title:title
													 message:msg
											 denyButtonTitle:denyTitle
											grantButtonTitle:grantTitle
										   completionHandler:^(BOOL hasPermission,
															   ClusterDialogResult userDialogResult,
															   ClusterDialogResult systemDialogResult) {
											   if (hasPermission) {
												   //Permission granted
												   
											   } else {
												   //No permission
											   }
											   NSLog(@"\nPermission: %@\nUser: %ld\nSystem: %ld.", hasPermission, (long)userDialogResult, (long)systemDialogResult);
										   }];
}

- (void)setupGoogleAnalytics {
	// Google Analytics setup for the app
	[GAI sharedInstance].trackUncaughtExceptions = YES;
	[[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
	[GAI sharedInstance].dispatchInterval = 120;
//TODO: Enable Google Analytics
	id<GAITracker> tracker =[ [GAI sharedInstance] trackerWithTrackingId:@"XX-11111111-1"];
	//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-53202813-1"];
	tracker.allowIDFACollection = NO;
}

- (void)setupLaunchKit {
	//Initialize LaunchKit info
//TODO: Enable LaunchKit
	//[LaunchKit launchWithToken:@"6Ms7MJIwN142MdBpvohTgVUCflw4yYEGPn-VOkZHkmO1"];
}

- (void)setupAppbotX {
	// Initialize AppbotX info
	[[ABXApiClient instance]
	 setApiKey:@"5b0feb30a4f023f3897789f9b38ab62304ee4790"];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
