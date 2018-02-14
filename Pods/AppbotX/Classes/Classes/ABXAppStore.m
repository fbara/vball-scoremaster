//
//  ABXAppStore.m
//
//  Created by Stuart Hall on 18/06/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXAppStore.h"

@implementation ABXAppStore

+ (void)openAppStoreReviewForApp:(NSString*)itunesId
{
   NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS 9 changes the app store links.
        NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software", itunesId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else if ([version compare:@"7.1" options:NSNumericSearch] != NSOrderedAscending) {
        // Since 7.1 we can throw to the review tab
        NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&ct=appbotReviewPrompt&at=11l4LZ&type=Purple%%252BSoftware&mt=8&sortOrdering=2", itunesId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else {
        [self openAppStoreForApp:itunesId];
    }
}

+ (void)openAppStoreForApp:(NSString*)itunesId
{
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/au/app/app/id%@?mt=8", itunesId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
