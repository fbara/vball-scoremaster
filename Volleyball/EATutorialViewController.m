//
//  EATutorialViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 8/18/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "EATutorialViewController.h"


static NSString * const tutorialPage1 = @"Here you see the main page with all the controls you need to keep score.  Above each score, enter the names of the teams that are playing.";
static NSString * const tutorialPage2 = @"";
static NSString * const tutorialPage3 = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
static NSString * const tutorialPage4 = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
static NSString * const tutorialPage5 = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

@interface EATutorialViewController ()


@end

@implementation EATutorialViewController

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
    // Do any additional setup after loading the view.
     
    // using self.navigationController.view - to display EAIntroView above navigation bar
    //rootView = self.navigationController.view;
}

///
- (void)showMainIntro
{
    EAIntroPage *mainPage1 = [EAIntroPage page];
    mainPage1.title = @"Welcome to VBall ScoreMaster!"; 
    mainPage1.desc = tutorialPage1;
    mainPage1.bgImage = [UIImage imageNamed:@"tutorialMain1"];
    
    EAIntroPage *mainPage2 = [EAIntroPage page];
    mainPage1.title = @"Social Sharing!";
    mainPage1.desc = tutorialPage2;
    mainPage1.bgImage = [UIImage imageNamed:@"tutorialMain2"];
    
//    EAIntroPage *mainPage3 = [EAIntroPage page];
//    mainPage1.title = @"Welcome to VBall ScoreMaster!";
//    mainPage1.desc = tutorialPage1;
//    mainPage1.bgImage = [UIImage imageNamed:@"tutorialMain3"];
    
    
    EAIntroView *mainIntro = [[EAIntroView alloc] initWithFrame:self.view.window.bounds
                                                       andPages:@[mainPage1, mainPage2]];
    [mainIntro setDelegate:self];
    [mainIntro showInView:self.view animateDuration:0.3];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
