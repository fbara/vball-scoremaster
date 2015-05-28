//
//  iPadTutorialSettingsBallViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 9/1/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "iPadTutorialSettingsBallViewController.h"

@interface iPadTutorialSettingsBallViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;

@end

@implementation iPadTutorialSettingsBallViewController

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
    [self.tutorialImage setImage:[UIImage imageNamed:@"iPadTutorialImageSettings"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Show coachMarks
    NSArray *coachMarks = @[
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{247.0f,129.0f},{530.0f,133.0f}}],
            @"caption": @"You can change the background color of each team's scorebox and we've added new color schemes.\n\nYou can also alternate between Regular, Dark, and Colorful themes."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{247.0f,284.0f},{530.0f,119.0f}}],
            @"caption": @"You decide when to send text messages and you can optionally include your player's name"
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{247.0f,390.0f},{530.0f,54.0f}}],
            @"caption": @"Choose text message recipients from your contact list or just enter their number directly."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{247.0f,593.0f},{530.0f,111.0f}}],
            @"caption": @"Select Actions from a list of common terms and choose the right one for your player's position."
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{512.0f,170.0f},{0.0f,0.0f}}],
            @"caption": @"There is help and information by tapping ⓘ in Settings.\n\nPlease leave feedback in the App Store, it helps others find the app!\n(tap to dismiss)"
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
    coachMarksView.enableContinueLabel = FALSE;
    [coachMarksView start];
}

- (void)coachMarksView:(WSCoachMarksView *)coachMarksView didNavigateToIndex:(NSUInteger)index
{
    //Check the index of the last shown coach mark.  It will be equal to the next mark
    //to be shown.  If it is >, we're done so exit from the view controller
    //If it's greater than the index of the last mark, segue to the Settings
    if (index > 4) {
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
