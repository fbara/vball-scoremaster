//
//  IAPItems.m
//  IAPExample
//
//  Created by AppleAir on 5/16/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "IAPItems.h"

@implementation IAPItems

+(IAPItems *)sharedInstance;
{
    static dispatch_once_t once;
    static IAPItems *sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:@"BaraTech.IAPExample.unlockSounds", nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    
    });
    return sharedInstance;
}

@end
