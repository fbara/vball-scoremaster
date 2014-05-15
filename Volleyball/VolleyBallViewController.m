//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "VolleyBallViewController.h"

@interface VolleyBallViewController ()

@end

@implementation VolleyBallViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.homeScoreView.backgroundColor = [UIColor blueColor];
    //self.homeScoreView.scoreLabel.font = [UIFont fontWithName:@"Thonburi-Bold" size:140.0f];
    //self.homeScoreView.center = self.view.center;
    self.homeScoreView.score = 25;
    self.visitorScoreView.score = 9;
    [self.view setNeedsDisplay];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
