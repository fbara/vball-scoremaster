//
//  iPadTutorialViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 9/1/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "iPadTutorialViewController.h"

@interface iPadTutorialViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;

@end

@implementation iPadTutorialViewController

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
    [self.tutorialImage setImage:[UIImage imageNamed:@"iPadTutorialImageMain"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Create coachMarks
    NSArray *coachMarks = @[
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{512.0f,170.0f},{0.0f,0.0f}}],
        @"caption": NSLocalizedString(@"Please take a minute to review the features of VBall ScoreMaster for the iPad.", @"Shown during the app tutorial")
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{73.0f,129.0f},{861.0f,60.0f}}],
        @"caption": NSLocalizedString(@"Customize the screen by adding the team names.", @"Shown during the app tutorial")
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{82.0f,185.0f},{844.0f,314.0f}}],
        @"caption": NSLocalizedString(@"Tap or swipe the scores to add and subtract points.\nFlick a scorebox with your finger to change sides when the teams change!", @"Shown during the app tutorial")
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{88.0f,537.0f},{838.0f,72.0f}}],
        @"caption": NSLocalizedString(@"Track your player's key actions using a variety of common measurements.", @"Shown during the app tutorial")
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{512.0f,170.0f},{0.0f,0.0f}}],
        @"caption": NSLocalizedString(@"Want to log the final scores for each game in a match?", @"Shown during the app tutorial")
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{10.0f,344.0f},{79.0f,171.0f}}],
        @"caption": @"VBall ScoreMaster tracks each team's final score\nand places it next to the team scorebox."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{334.0f,198.0f},{339.0f,297.0f}}],
        @"caption": @"You can send a pre-formatted text message just by tapping the VBall.\n\nYou don't have to take your eyes off the game to type out a message!"
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{88.0f,488.0f},{838.0f,69.0f}}],
        @"caption": @"Select the player Actions YOU want to track.\n\nMake changes in the Settings screen."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{391.0f,578.0f},{243.0f,96.0f}}],
        @"caption": @"Post the game highlights to Twitter or Facebook.\nEach post includes a screenshot of the score!"
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{510.0f,170.0f},{0.0f,0.0f}}],
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
    
    if (index > 8) {
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
