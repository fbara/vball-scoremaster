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
        @"caption": @"Here's a quick tour of the exciting new features of VBall ScoreMaster for the iPad."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{73.0f,129.0f},{861.0f,60.0f}}],
        @"caption": @"Customize the screen by adding the team names, and..."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{82.0f,185.0f},{844.0f,314.0f}}],
        @"caption": @"...tap and swipe the scores to add and subtract points.\nFlick a scorebox with your finger to change sides when the team change!"
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{93.0f,487.0f},{844.0f,127.0f}}],
        @"caption": @"Track your player's actions, using a variety of different measurements, with just a tap."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{512.0f,170.0f},{0.0f,0.0f}}],
        @"caption": @"One of the most requested features we've received is to track past game history, so..."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{10.0f,344.0f},{79.0f,171.0f}}],
        @"caption": @"...you can track past scores for each team in the same match."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{334.0f,198.0f},{339.0f,297.0f}}],
        @"caption": @"You can send a pre-formatted text message just by tapping the VBall..."
        },
    @{
        @"rect": [NSValue valueWithCGRect:(CGRect){{88.0f,488.0f},{838.0f,69.0f}}],
        @"caption": @"...and choose the player Actions YOU want to track.\n\nYou don't have to take your eyes off the game to type out a message!"
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
