//
//  TutorialSettingsViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/23/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "TutorialSettingsViewController.h"

@interface TutorialSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;

@end

@implementation TutorialSettingsViewController

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
    [self.tutorialImage setImage:[UIImage imageNamed:@"TutorialImageSettings1"]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Show coachMarks
    NSArray *coachMarks = @[
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{11.0f,55.0f},{546.0f,131.0f}}],
                @"caption": @"Send updates to anyone in your Contacts list"
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{11.0f,184.0f},{546.0f,100.0f}}],
                @"caption": @"Decide when to post highlights to Twitter© and Facebook©"
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{436.0f,188.0f},{124.0f,118.0f}}],
                @"caption": @"Select Actions from a list of common terms..."
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{8.0f,174.0f},{552.0f,140.0f}}],
                @"caption": @"...and choose the right one for your player"
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{281.0f,72.0f},{0.0f,0.0f}}],
                @"caption": @"There is help and information by tapping ⓘ in Settings.\nPlease leave feedback in the App Store, it helps others!\n(tap to dismiss)"
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
    coachMarksView.enableContinueLabel = FALSE;
    [coachMarksView start];
}

- (void)coachMarksView:(WSCoachMarksView *)coachMarksView didNavigateToIndex:(NSUInteger)index
{
	if (index == 2) {
		[self.tutorialImage setImage:[UIImage imageNamed:@"TutorialImageSettings2"]];
		return;
	}
	
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
