//
//  PermissionsVolleyBall.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 4/7/16.
//  Copyright © 2016 BaraLabs, LLC. All rights reserved.
//

#import "PermissionsVolleyBall.h"
#import <VWWPermissionKit/VWWPermissionKit.h>
#import <GBVersionTracking/GBVersionTracking.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <LaunchKit/LaunchKit.h>
@import CoreLocation;

@interface PermissionsVolleyBall ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (weak, nonatomic)NSUserDefaults *defaults;
@property (nonatomic, weak) NSString *randomUserString;

@end

@implementation PermissionsVolleyBall

- (void)requestPermissions {
    //Use VWWPermissions to request access
    VWWPhotosPermission *photoPerm = [VWWPhotosPermission permissionWithLabelText:NSLocalizedString(@"You can save your drawings and lists.  We need your permission to save them to your photo library", @"Message box to request permission to save drawings.")];
    VWWCoreLocationWhenInUsePermission *locPerm = [VWWCoreLocationWhenInUsePermission permissionWithLabelText:NSLocalizedString(@"When using the app, we save your location with the drawings.", @"Message box to request permission to save user location.")];
    NSArray *permissions = @[photoPerm, locPerm];
    __block BOOL isAnalyticsSetup = FALSE;
    
    //Need to get a handle to the active VC, otherwise the error msg won't be seen
    UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([activeVC isKindOfClass:[UINavigationController class]]) {
        activeVC = [(UINavigationController *)activeVC visibleViewController];
        NSLog(@"\nActive VC: %@", activeVC.title);
    }
    
    [VWWPermissionsManager optionPermissions:permissions
                                       title:NSLocalizedString(@"Welcome to VBall ScoreMaster. To get the best experience, we need to setup some device permissions. Let's setup those permissions now.", @"Tell the user we're going to setup the device permissions.")
                          fromViewController:[UIApplication sharedApplication].keyWindow.rootViewController
                                resultsBlock:^(NSArray *permissions) {
                                    [permissions enumerateObjectsUsingBlock:^(VWWPermission *permission, NSUInteger idx, BOOL *stop) {
                                        if ([permission.type isEqualToString:@"Photos"]) {
                                            if ([[permission stringForStatus] isEqualToString:@"Authorized"]) {
                                                //Opt in
                                                if (!isAnalyticsSetup) {
                                                    [self.defaults setObject:@"Opt in" forKey:@"analyticsChoice"];
                                                    [self enableGoogleAnalytics:TRUE];
                                                    [self enableLaunchKitAnalytics];
                                                    isAnalyticsSetup = TRUE;
                                                }
                                            } else {
                                                //Opt out
                                                [self enableGoogleAnalytics:FALSE];
                                                [self.defaults setObject:@"Opt out" forKey:@"analyticsChoice"];
                                            }
                                        }
                                        if ([permission.type isEqualToString:@"Location In Use"]) {
                                            if ([[permission stringForStatus] isEqualToString:@"Authorized"]) {
                                                //Opt in
                                                if (!isAnalyticsSetup) {
                                                    [self.defaults setObject:@"Opt in" forKey:@"analyticsChoice"];
                                                    [self enableGoogleAnalytics:TRUE];
                                                    [self enableLaunchKitAnalytics];
                                                    isAnalyticsSetup = TRUE;
                                                }
                                            } else {
                                                //Opt out
                                                [self.defaults setObject:@"Opt out" forKey:@"analyticsChoice"];
                                            }
                                        }
                                        
                                    }];
                                }];
    
}

- (void)enableGoogleAnalytics:(BOOL)status {
    if (status) {
        [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
        [[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
        [GAI sharedInstance].dispatchInterval = 120;
//TODO: *******Change Google App ID*******
        id<GAITracker> tracker =[ [GAI sharedInstance] trackerWithTrackingId:@"XX-11111111-1"];
//        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-53202813-1"];
        tracker.allowIDFACollection = NO;
        [[GAI sharedInstance] setOptOut:NO];
    } else {
        [[GAI sharedInstance] setOptOut:YES];
    }
    

}

- (void)enableLaunchKitAnalytics {
//TODO: *******Change LaunchKit App ID*******
//    [LaunchKit launchWithToken:@"6Ms7MJIwN142MdBpvohTgVUCflw4yYEGPn-VOkZHkmO1"];
    self.randomUserString = [self.defaults objectForKey:@"userString"];
//    [[LaunchKit sharedInstance] setUserIdentifier:self.randomUserString email:[self.randomUserString stringByAppendingString:@"@email.com"] name:self.randomUserString];

    
}

@end
