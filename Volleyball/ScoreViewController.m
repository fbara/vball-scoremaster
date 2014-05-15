//
//  ScoreViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/15/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "ScoreViewController.h"

@interface ScoreViewController ()
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end

@implementation ScoreViewController
@synthesize score;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setScore:(int)aScore
{
	//Takes the score that it's sent and uses it to update the score label
    score = aScore;
	self.scoreLabel.text = [NSString stringWithFormat:@"%d", aScore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
