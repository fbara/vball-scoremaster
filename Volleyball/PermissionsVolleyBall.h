//
//  PermissionsVolleyBall.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 4/7/16.
//  Copyright © 2016 BaraLabs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PermissionsVolleyBall : UIViewController

- (void)requestPermissions;
- (void)setupGoogleAnalytics;
- (void)setupLaunchKitAnalytics;

@end
