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
                @"rect": [NSValue valueWithCGRect:(CGRect){{20.0f,55.0f},{528.0f,30.0f}}],
                @"caption": @"You decide when to send text messages..."
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{299.0f,145.0f},{249.0f,30.0f}}],
                @"caption": @"...and you can choose from your list of contacts."
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{14.0f,232.0f},{191.0f,80.0f}}],
                @"caption": @"Select Actions from a list of common terms..."
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{438.0f,230.0f},{115.0f,80.0f}}],
                @"caption": @"...and choose the right one for your player."
                },
            @{
                @"rect": [NSValue valueWithCGRect:(CGRect){{281.0f,72.0f},{0.0f,0.0f}}],
                @"caption": @"Thanks for using VBall ScoreMaster!\n(tap to begin)"
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
    //Check the index of the last shown coach mark.  It will be equal to the next mark
    //to be shown.  If it is >, we're done so exit from the view controller
    //If it's greater than the index of the last mark, segue to the Settings
    if (index > 4) {
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
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
