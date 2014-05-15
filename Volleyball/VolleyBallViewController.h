//
//  VolleyBallViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreView.h"

@interface VolleyBallViewController : UIViewController

@property (strong, nonatomic) IBOutlet ScoreView *homeScoreView;
@property (strong, nonatomic) IBOutlet ScoreView *visitorScoreView;
@end
