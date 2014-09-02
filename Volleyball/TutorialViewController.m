//
//  TutorialViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/22/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;

@end

@implementation TutorialViewController

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
    [self.tutorialImage setImage:[UIImage imageNamed:@"TutorialImageMain"]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Create coachMarks
    NSArray *coachMarks = @[
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{281.0f,72.0f},{0.0f,0.0f}}],
            @"caption": @"Here's a quick tour of the features of VBall ScoreMaster."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{62.0f,71.0f},{439.0f,30.0f}}],
            @"caption": @"Customize the screen by adding team names, and..."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{62.0f,97.0f},{439.0f,150.0f}}],
            @"caption": @"...tap to add points and swipe the scores to change sides."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{118.0f,275.0f},{327.0f,30.0f}}],
            @"caption": @"Track your player's actions with just a tap."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{281.0f,72.0f},{0.0f,0.0f}}],
            @"caption": @"One of the most requested features we've recieved..."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{14.0f,157.0f},{40.0f,98.0f}}],
            @"caption": @"...you can track past scores in the same match..."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{241.0f,149.0f},{80.0f,80.0f}}],
            @"caption": @"...send a text with the game score by tapping the VBall..."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{62.0f,255.0f},{439.0f,25.0f}}],
            @"caption": @"...and choose the player Actions YOU want to track."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{280.0f,0.0f},{0.0f,0.0f}}],
            @"caption": @""
            }
        ];
    //Array of marks is created, now show them
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    coachMarksView.delegate = self;
    [self.view addSubview:coachMarksView];
    [coachMarksView start];

}

- (void)coachMarksView:(WSCoachMarksView *)coachMarksView didNavigateToIndex:(NSUInteger)index
{
    //Check the index of the last shown coach mark.  It will be equal to the next mark
    //to be shown.  If it is >, we're done so exit from the view controller
    //If it's greater than the index of the last mark, segue to the Settings
    
    if (index > 7) {
        [self performSegueWithIdentifier:@"showTutorialSettings" sender:self];
    }
}

- (void)coachMarksViewDidCleanup:(WSCoachMarksView *)coachMarksView
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
