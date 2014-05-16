//
//  VolleyBallViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VolleyBallViewController : UIViewController <UIPageViewControllerDataSource>

@property UIColor *homeColor;
@property UIColor *visitorColor;

- (IBAction)reset;
@end
