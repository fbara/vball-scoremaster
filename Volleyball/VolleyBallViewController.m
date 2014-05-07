//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "VolleyBallViewController.h"

@interface VolleyBallViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelPantherScore;
@property (weak, nonatomic) IBOutlet UILabel *labelOtherTeamScore;

@end

@implementation VolleyBallViewController

- (IBAction)btnPantherTouch:(UIButton *)sender forEvent:(UIEvent *)event
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Alert"
                          message:@"Change Panther score!"
                          delegate:nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    
    [alert show];
}
- (IBAction)btnReset
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
