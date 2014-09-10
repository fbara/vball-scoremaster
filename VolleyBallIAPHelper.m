//
//  VolleyBallIAPHelper.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 9/9/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "VolleyBallIAPHelper.h"

@implementation VolleyBallIAPHelper

+ (VolleyBallIAPHelper *)sharedInstance
{
    //Create a singleton to return a global instance of VolleyBallIAPHelper class
    //This calls the superclass initializer to pass in the product identifiers
    //created on iTunes Connect
    static dispatch_once_t once;
    static VolleyBallIAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:@"com.baralabs.vballscoremaster.social", nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
