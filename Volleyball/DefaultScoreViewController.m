//
//  DefaultScoreViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/16/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "DefaultScoreViewController.h"

@interface DefaultScoreViewController ()

@property(weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation DefaultScoreViewController
@synthesize score;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setScore:(int)aScore {
  score = aScore;
  self.scoreLabel.text = [NSString stringWithFormat:@"%d", aScore];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.

  //[[NSNotificationCenter defaultCenter] postNotificationName:@"swipe"
  // object:self];
}

- (void)setScoreNumberSize:(CGFloat)numberSize {
  [self.scoreLabel
      setFont:[UIFont fontWithName:@"Trebuchet MS" size:numberSize]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
