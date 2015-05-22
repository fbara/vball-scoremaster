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
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.1" options:NSNumericSearch] != NSOrderedAscending) {
        // Since 7.1 we can throw to the review tab
        NSString *url = [NSString stringWithFormat:@"http://geo.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&ct=applink&at=1001lDi&type=Purple%%252BSoftware&mt=8&sortOrdering=2", itunesId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else {
        [self openAppStoreForApp:itunesId];
    }
}

+ (void)openAppStoreForApp:(NSString*)itunesId
{
    NSString *url = [NSString stringWithFormat:@"https://geo.itunes.apple.com/us/app/vball-scoremaster/%@?mt=8&uo=6&at=1001lDi&ct=applink", itunesId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
