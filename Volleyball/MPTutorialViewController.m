//
//  MPTutorialViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 11/9/15.
//  Copyright © 2015 BaraLabs, LLC. All rights reserved.
//

#import "MPTutorialViewController.h"

@interface MPTutorialViewController ()

@property (weak, nonatomic)IBOutlet UIImageView *tutorialImage;

@end

@implementation MPTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.tutorialImage setImage:[UIImage imageNamed:@"TutorialImageMain"]];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self showCoachMarks];
}

#pragma mark - Create/Display
-(void)showCoachMarks {
	
	//Create coachMarks
	NSArray *coachMarks = @[
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{281.0f,72.0f},{0.0f,0.0f}}],
					@"caption": NSLocalizedString(@"Here's a quick tour of the features of VBall ScoreMaster", @"Shown during the app tutorial")
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{62.0f,58.0f},{439.0f,30.0f}}],
					@"caption": NSLocalizedString(@"Customize the scores by adding the team names", @"Shown during the app tutorial"),
					@"position": [NSNumber numberWithInteger:LABEL_POSITION_BOTTOM],
					@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER],
					@"showArrow": [NSNumber numberWithBool:YES]
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{62.0f,120.0f},{439.0f,105.0f}}],
					@"caption": NSLocalizedString(@"Tap to add points and swipe the scores <-- --> to change sides", @"Shown during the app tutorial"),
					@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
					@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER],
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{118.0f,275.0f},{327.0f,30.0f}}],
					@"caption": NSLocalizedString(@"Track your player's main actions with just a tap", @"Shown during the app tutorial"),
					@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
					@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER]
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{281.0f,72.0f},{0.0f,0.0f}}],
					@"caption": NSLocalizedString(@"Want to log the final scores for each game in a match?", @"Shown during the app tutorial")
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{14.0f,157.0f},{40.0f,98.0f}}],
					@"caption": NSLocalizedString(@"VBall ScoreMaster tracks the past final scores and puts them on each side", @"Shown during the app tutorial"),
					@"position": [NSNumber numberWithInteger:LABEL_POSITION_RIGHT],
					@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_CENTER]
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{241.0f,149.0f},{80.0f,80.0f}}],
					@"caption": NSLocalizedString(@"Send a message anytime by tapping the VBall (Have 3D Touch? Try it here!)", @"Shown during the app tutorial"),
					@"showArrow": [NSNumber numberWithBool:NO],
					@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
					@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT]
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{62.0f,255.0f},{439.0f,25.0f}}],
					@"caption": NSLocalizedString(@"Select the player Actions YOU want to track (Have 3D Touch? Try it here!)", @"Shown during the app tutorial")
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{226.0f,265.0f},{113.0f,47.0f}}],
					@"caption": NSLocalizedString(@"Easily post updates to Twitter & Facebook\n(in-app purchase)", @"Shown during the app tutorial"),
					@"showArrow": [NSNumber numberWithBool:YES],
					@"shape": [NSNumber numberWithInteger:SHAPE_CIRCLE],
					@"position": [NSNumber numberWithInteger:LABEL_POSITION_TOP],
					@"alignment": [NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT]
					},
				@{
					@"rect": [NSValue valueWithCGRect:(CGRect){{280.0f,0.0f},{0.0f,0.0f}}],
					@"caption": @""
					}
				];

	MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
	coachMarksView.delegate = self;
	[self.view addSubview:coachMarksView];
	[coachMarksView start];
	
}

#pragma mark - CoachMarks Delegates

-(void)coachMarksView:(MPCoachMarks *)coachMarksView didNavigateToIndex:(NSUInteger)index {
	//Check the index of the last shown coach mark.  It will be equal to the next mark
	//to be shown.  If it is >, we're done so exit from the view controller
	//If it's greater than the index of the last mark, segue to the Settings
	
	if (index > 8) {
		[self performSegueWithIdentifier:@"showTutorialSettings" sender:self];
	}
}

-(void)coachMarksViewDidCleanup:(MPCoachMarks *)coachMarksView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:TRUE forKey:@"tutorialShown"];
	[self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
