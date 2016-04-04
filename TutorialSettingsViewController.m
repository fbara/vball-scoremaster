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
    [self.tutorialImage setImage:[UIImage imageNamed:@"TutorialImageSettings"]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Show coachMarks
    NSArray *coachMarks = @[
			@{
				@"rect": [NSValue valueWithCGRect:(CGRect){{11.0f,63.0f},{547.0f,120.0f}}],
				@"caption": NSLocalizedString(@"Tap the color box to change the score color", @"Shown during the app tutorial"),
				@"showArrow": [NSNumber numberWithBool:YES]
				},
			@{
                @"rect": [NSValue valueWithCGRect:(CGRect){{6.0f,103.0f},{556.0f,136.0f}}],
                @"caption": NSLocalizedString(@"Send messages to anyone in your Contacts list", @"Shown during the app tutorial"),
				@"showArrow": [NSNumber numberWithBool:NO],
				@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
				@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER]
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{6.0f,96.0f},{556.0f,57.0f}}],
                @"caption": NSLocalizedString(@"New in this version, decide the type of message to send or post!", @"Shown during the app tutorial"),
                @"showArrow": [NSNumber numberWithBool:YES],
                @"position": [NSNumber numberWithInteger:LABEL_POSITION_BOTTOM],
                @"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER]
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{11.0f,184.0f},{546.0f,100.0f}}],
				@"caption": NSLocalizedString(@"Decide when to post highlights to Twitter and Facebook\n(in-app purchase)", @"Shown during the app tutorial"),
				@"showArrow": [NSNumber numberWithBool:YES],
				@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
				@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT]
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{436.0f,188.0f},{124.0f,118.0f}}],
				@"caption": NSLocalizedString(@"Select an existing Action Name or create your own to track your player...", @"Shown during the app tutorial"),
				@"showArrow": [NSNumber numberWithBool:YES],
				@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
				@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT]
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{8.0f,174.0f},{552.0f,140.0f}}],
				@"caption": NSLocalizedString(@"...and assign them to locations on the main screen!", @"Shown during the app tutorial"),
				@"showArrow": [NSNumber numberWithBool:YES],
				@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
				@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER]
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{281.0f,72.0f},{0.0f,0.0f}}],
                @"caption": NSLocalizedString(@"Use 3D Touch on Home Screen icon to start a new game or match. There is help and information by tapping ⓘ in Settings.\nPlease leave feedback in the App Store, it helps others!\n(tap to dismiss)", @"Shown during the app tutorial")
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{280.0f,0.0f},{0.0f,0.0f}}],
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
	if (index == 1) {
		[self.tutorialImage setImage:[UIImage imageNamed:@"TutorialImageSettings1"]];
		return;
	}
	
	if (index == 3) {
		[self.tutorialImage setImage:[UIImage imageNamed:@"TutorialImageSettings2"]];
		return;
	}
	
	//Check the index of the last shown coach mark.  It will be equal to the next mark
    //to be shown.  If it is >, we're done so exit from the view controller
    //If it's greater than the index of the last mark, segue to the Settings
    if (index > 6) {
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
