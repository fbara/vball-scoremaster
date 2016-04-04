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
            @"rect": [NSValue valueWithCGRect:(CGRect){{253.0f,75.0f},{519.0f,134.0f}}],
            @"caption": NSLocalizedString(@"Tap the color box to change the background color of each team's scorebox to match their uniforms.\nUse a custom color to get the exact match!.\n\nAlternate between Regular, Dark, and Colorful app themes.", @"Shown during the app tutorial")
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{247.0f,221.0f},{519.0f,212.0f}}],
            @"caption": NSLocalizedString(@"You decide when to send text messages and even include your player's name to personalize the message or post.", @"Shown during the app tutorial")
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{247.0f,281.0f},{519.0f,68.0f}}],
            @"caption": NSLocalizedString(@"New with this version, you can select the type of message or post.\n\nExperiment and have fun!.", @"Shown during the app tutorial")
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{253.0f,578.0f},{519.0f,129.0f}}],
            @"caption": NSLocalizedString(@"Select Actions from a list of common terms or create your own, customize the Actions to fit your player.", @"Shown during the app tutorial"),
			@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
			@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER]
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{512.0f,170.0f},{0.0f,0.0f}}],
            @"caption": NSLocalizedString(@"There is help and information by tapping ⓘ in Settings.\n\nPlease leave feedback in the App Store, it helps others find the app!\n(tap to dismiss)", @"Shown during the app tutorial. The i in the circle represents the 'info' button on Settings screen")
            },
        @{
            @"rect": [NSValue valueWithCGRect:(CGRect){{510.0f,170.0f},{0.0f,0.0f}}],
            @"caption": @""
            }
        ];
    //Array of marks is created, now show them
    MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    coachMarksView.delegate = self;
    [self.view addSubview:coachMarksView];
    coachMarksView.enableContinueLabel = FALSE;
    [coachMarksView start];
}

- (void)coachMarksView:(MPCoachMarks *)coachMarksView didNavigateToIndex:(NSUInteger)index
{
    //Check the index of the last shown coach mark.  It will be equal to the next mark
    //to be shown.  If it is >, we're done so exit from the view controller
    //If it's greater than the index of the last mark, segue to the Settings
    if (index > 4) {
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)coachMarksViewDidCleanup:(MPCoachMarks *)coachMarksView
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
