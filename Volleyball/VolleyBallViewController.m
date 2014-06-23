//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "VolleyBallViewController.h"
#import "DefaultScoreViewController.h"
#import "SettingsViewController.h"

//Constants for use when extending this to other sports
NSString *const EMBED_HOME = @"embedHome";
NSString *const EMBED_VISITOR = @"embedVisitor";
int currHomeScore = 0;
int currVisitorScore = 0;
int currKill = 0;
int currAce = 0;
NSString *msgHome = @"HOME";
NSString *msgVisitor = @"VISITOR";

//BOOL ROTATED = NO;
//BOOL SWIPED = NO;
////define PI
//#define M_PI   3.14159265358979323846264338327950288
////Conversion definition
//#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)


@interface VolleyBallViewController ()


@property (weak, atomic)UIPageViewController *homePageViewController;
@property (weak, atomic)UIPageViewController *visitorPageViewController;
@property (weak, nonatomic)UITextField *activeField;
@property (weak, nonatomic) IBOutlet UILabel *gameLabel;
@property (weak, nonatomic) IBOutlet UILabel *spikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *aceLabel;


@end

@implementation VolleyBallViewController


#pragma mark - Initialize Screen

//Called first, before the main view controller is loaded
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:EMBED_HOME]) {
        self.homePageViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:EMBED_VISITOR]) {
        self.visitorPageViewController = segue.destinationViewController;
    }
    
}

//Called second, after the segue's are setup
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initializeHomeScore:currHomeScore];
    [self initializeVisitorScore:currVisitorScore];
    [self resetGameKillAce];
    self.visitingTeamName.delegate = self;
    self.homeTeamName.delegate = self;
    
    // Create Home swipe gesture and add it to the home container view.
    // Set this controller as the delegate to allow simultaneous gestures in the PageViewController's container view
    UISwipeGestureRecognizer *homeSwipeGesture = [[UISwipeGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(handleSwipe:)];
    homeSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    homeSwipeGesture.delegate = self;
    [_homeTeamContainer addGestureRecognizer:homeSwipeGesture];
    
    //Create the same thing for the visitor team container
    UISwipeGestureRecognizer *visitorSwipeGesture = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handleSwipe:)];
    visitorSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    visitorSwipeGesture.delegate = self;
    [_vistingTeamContainer addGestureRecognizer:visitorSwipeGesture];
    
    /*! Loop through all the gesture recognizers on each of the pageview controllers,
     *  and when you locate either the tap or pan recognizers, set them to require the
     *  appropriate swipe gesture to fail before they'll recognize their gesture.
     */
    
    for (UIGestureRecognizer *gesture in _homePageViewController.view.gestureRecognizers)
	{
		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:homeSwipeGesture];
            
		}
        
		if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:homeSwipeGesture];
		}
	}
    
	for (UIGestureRecognizer *gesture in _visitorPageViewController.view.gestureRecognizers)
	{
		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:visitorSwipeGesture];
		}
        
		if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:visitorSwipeGesture];
		}
	}


}

- (void)initializeHomeScore:(int)score
{
    self.homeColor = [self colorHomeScoreView];
    DefaultScoreViewController *homeScoreViewController = [self createViewControllersForScore:score
                                                                             withColor:self.homeColor];
    self.homePageViewController.dataSource = self;
    [self.homePageViewController setViewControllers:@[homeScoreViewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];

    
}

- (void)initializeVisitorScore:(int)score
{
    self.visitorColor = [self colorVisitorScoreView];
    DefaultScoreViewController *visitorScoreViewController = [self createViewControllersForScore:score
                                                                                withColor:self.visitorColor];
    self.visitorPageViewController.dataSource = self;
    [self.visitorPageViewController setViewControllers:@[visitorScoreViewController]
                                             direction:UIPageViewControllerNavigationDirectionForward
                                              animated:NO
                                            completion:nil];
    
}

- (DefaultScoreViewController *)createViewControllersForScore:(int)score withColor:(UIColor *)color
{
    //Create a new scoreViewController and initialize it with 'nil',
    //that will create one with a xib of the same name
    DefaultScoreViewController *newScoreViewController = [[DefaultScoreViewController alloc]
                                                   initWithNibName:nil
                                                   bundle:nil];
    //Set the properties of the score view
    newScoreViewController.view.backgroundColor = color;
    newScoreViewController.score = score;
    
    return newScoreViewController;
}

- (UIColor *)colorHomeScoreView
{
    //Get home team background colors
    UIColor *colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theHomeData = [[NSUserDefaults standardUserDefaults] dataForKey:@"homeTeamColor"];
    if (theHomeData != nil) {
        colorHome = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theHomeData];
    } else {
        colorHome = [UIColor blueColor];
    }
    return colorHome;
}

- (UIColor *)colorVisitorScoreView
{
    //Get visiting team background colors
    UIColor *colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theVisitorData = [[NSUserDefaults standardUserDefaults] dataForKey:@"visitorTeamColor"];
    if (theVisitorData != nil) {
        colorVisitor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theVisitorData];
    } else {
        colorVisitor = [UIColor orangeColor];
    }
    return colorVisitor;
}

- (void)resetGameKillAce
{
    //Resets Game, Kill, and Ace to 0
    self.gameNumber.text = @"1";
    self.killNumber.text = @"0";
    self.aceNumber.text = @"0";
    currAce = 0;
    currKill = 0;
    currHomeScore = 0;
    currVisitorScore = 0;
}

/*!
 * @discussion Refresh the screen immediately before app is visible
 * @param animated Bool value to indicate if animations should be used
 */
- (void)viewWillAppear:(BOOL)animated
{
    //Update the scoreview's colors in case they were changed in Settings
    [self initializeVisitorScore:currVisitorScore];
    [self initializeHomeScore:currHomeScore];
    
    [super viewWillAppear:animated];
}

#pragma mark - UI Elements

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIPanGestureRecognizers

/*!
 * @discussion Handle the swipe gesture to swap positions of scoreviews
 * @param recognizer UIGestureRecognizer to indicate what type of gesture is being sent
 */
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    //Get the center of each score view container
    CGPoint targetHomeCenter = _vistingTeamContainer.center;
    CGPoint targetVisitorCenter = _homeTeamContainer.center;
    CGPoint targetHomeNameCenter = _visitingTeamName.center;
    CGPoint targetVisitorNameCenter = _homeTeamName.center;
    
    //Create the animation and swap positions of the score controllers
    [UIView animateWithDuration:0.7f
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         _homeTeamContainer.center = targetHomeCenter;
                         _homeTeamName.center = targetHomeNameCenter;
                         _vistingTeamContainer.center = targetVisitorCenter;
                         _visitingTeamName.center = targetVisitorNameCenter;
                     }
                     completion:NULL];
}

#pragma mark - UIGestureRecognizer Delegate Method

// Force all gestures to be handled simultaneously.
//This will allow the Swipes and PageViewController's Pan/Tap gestures to coexsist and function correctly.
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UILongPressGestureRecognizers

- (IBAction)topActionLongPress:(UILongPressGestureRecognizer *)recognizer
{
    //On a long press, show popup menu with selections to reset the number to zero or not
    
    [self.aceNumber canBecomeFirstResponder];
    
    UIMenuItem *yes = [[UIMenuItem alloc] initWithTitle:@"Reset to 0" action:@selector(resetTopToZero)];
    //"Leave as is" and "Cance" both do the same thing, nothing right now.
    UIMenuItem *no = [[UIMenuItem alloc] initWithTitle:@"Leave as is" action:@selector(leaveNumberAsIs)];
    UIMenuItem *cancel = [[UIMenuItem alloc] initWithTitle:@"Cancel" action:@selector(leaveNumberAsIs)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:yes, no, cancel, nil]];
    [menu setTargetRect:self.aceNumber.frame inView:self.view];
    [menu setMenuVisible:YES animated:YES];
}

- (IBAction)bottomActionLongPress:(UILongPressGestureRecognizer *)recognizer
{
    //On a long press, show popup menu with selections to reset the number to zero or not
    
    [self.killNumber canBecomeFirstResponder];
    
    UIMenuItem *yes = [[UIMenuItem alloc] initWithTitle:@"Reset to 0" action:@selector(resetBottomToZero)];
    //"Leave as is" and "Cance" both do the same thing, nothing right now.
    UIMenuItem *no = [[UIMenuItem alloc] initWithTitle:@"Leave as is" action:@selector(leaveNumberAsIs)];
    UIMenuItem *cancel = [[UIMenuItem alloc] initWithTitle:@"Cancel" action:@selector(leaveNumberAsIs)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:yes, no, cancel, nil]];
    [menu setTargetRect:self.killNumber.frame inView:self.view];
    [menu setMenuVisible:YES animated:YES];}


- (void)resetTopToZero
{
    self.aceNumber.text = @"0";
}

- (void)resetBottomToZero
{
    self.killNumber.text = @"0";
}

- (void)leaveNumberAsIs
{
    //Dummy method to allow UIMenuItems to be visible
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
//- (void)resetTopNumbersActionSheet
//{
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:@"Reset back to 0?"
//                                  delegate:nil
//                                  cancelButtonTitle:@"No"
//                                  destructiveButtonTitle:@"Yes"
//                                  otherButtonTitles:nil];
//    [actionSheet showInView:self.view];
//}

#pragma mark - Button Presses
/*!
 *  What happens when 'Game' number is touched
 */
- (IBAction)gamePressed
{
    //Grab the game number
    int lableNum = [self.gameNumber.text intValue];

    lableNum = lableNum + 1;
    
    if (lableNum <= 7) {
        self.gameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
        
        //Reset the scores to start a new game
        [self initializeHomeScore:0];
        [self initializeVisitorScore:0];
    } else {
        self.gameNumber.text = [NSString stringWithFormat:@"%d", 0];

    }
 
}

/*!
 *  What happens when 'Spike' number is touched
 */
- (IBAction)killsPressed
{
    //Get the number currently displayed for kills and add 1
    int lableNum = [self.killNumber.text intValue];
    if (lableNum == 99) {
        lableNum = 0;
    } else {
        lableNum = lableNum + 1;
    }
    self.killNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    currKill = lableNum;
    
    //Send text message
    [self sendSMS];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*!
 *  What happens when 'Ace' number is touched
 */
- (IBAction)acePressed
{
    //Get current number and add 1
    int lableNum = [self.aceNumber.text intValue];
    if (lableNum == 99) {
        lableNum = 0;
    } else {
        lableNum = lableNum + 1;
    }
    self.aceNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    currAce = lableNum;
    
    //Send the text message
    [self sendSMS];
}

/*!
 *  What happens when 'New Match' button is touched
 */
- (IBAction)newMatch
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Match?", nil)
                                                        message:NSLocalizedString(@"Reset scores, ace's, spike's and start a new match?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self initializeHomeScore:0];
        [self initializeVisitorScore:0];
        [self resetGameKillAce];

    }
}

/*!
 * @discussion Takes in an image and rotates it by the given degrees.
 * @param image The image that will be rotated.
 * @param duration How long the animation should take.
 * @param degrees How many degrees the image should be rotated.
 * @warning You can't send a negative number to 'degrees', must be positive value.
 */
//- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
//            degrees:(CGFloat)degrees
//{
//    
//    [UIView animateWithDuration:duration
//                          delay:0.0f
//         usingSpringWithDamping:0.8f
//          initialSpringVelocity:0.9f
//                        options:UIViewAnimationOptionBeginFromCurrentState
//                     animations:^(){
//                         CGAffineTransform transform =
//                         CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
//                         image.transform = transform;
//                     }
//                     completion:NULL];
//    
//}

/*!
 * @discussion Checks the current rotation of the team serving arrow and rotates it.
 */
//- (IBAction)teamServingDirection
//{
//    /*!
//     *  Checks the current rotation of the team serving arrow.
//     *  Rotate it every time this button is pressed.
//     */
//    if (!ROTATED) {
//
//    [self rotateImage:self.serveDirectionArrow
//            duration:0.4
//             degrees:180];
//        ROTATED = YES;
//    } else {
//    [self rotateImage:self.serveDirectionArrow
//             duration:0.4
//              degrees:360];
//        ROTATED = NO;
//    }
//}

- (void)sendSMS
{
    // Check if text messages should be sent
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults stringForKey:@"enableNotifications"] isEqualToString:@"On"]) {
        
        //Send the SMS message
        //If it can't be sent, iOS will pop up an alert so we don't have to do that
        MFMessageComposeViewController *textComposer = [[MFMessageComposeViewController alloc] init];
        [textComposer setMessageComposeDelegate:self];
        
        if ([MFMessageComposeViewController canSendText]) {
            NSString *playerName = [defaults stringForKey:@"playerNameForNotifications"];
            NSString *notificationNumber = [defaults stringForKey:@"phoneNumberForNotification"];
            
            NSString *textMessage = [NSString stringWithFormat:@"%@ has %d spikes and %d aces!\nThe score is now %@ %d - %@ %d.", playerName ,currKill, currAce, msgVisitor, currVisitorScore, msgHome, currHomeScore];
            [textComposer setRecipients:[NSArray arrayWithObjects:notificationNumber, nil]];
            
            [textComposer setBody:textMessage];
            [self presentViewController:textComposer
                               animated:YES
                             completion:nil];
        }
    }//No messages to be sent, exit
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
        //Cast the viewController as a ScoreViewController so we can act on its properties
        DefaultScoreViewController *oldViewController = (DefaultScoreViewController *)viewController;
        
        //Check the score, if it's more than 99, don't let the number get any higher
        if (oldViewController.score == 99) {
            return nil;
        }
        
        //Setup the new view controller with the new, higher score
        DefaultScoreViewController *newViewController = [self createViewControllersForScore:0
                                                                           withColor:[UIColor clearColor]];
        newViewController.score = oldViewController.score + 1;
        
        //Check to see which view controller we're updating so the background color can be set correctly
        if (pageViewController == _homePageViewController) {
            //Home team score changing
            newViewController.view.backgroundColor = self.homeColor;
            currHomeScore = newViewController.score;
            msgHome = [NSString stringWithString:self.homeTeamName.text];
            msgVisitor = [NSString stringWithString:self.visitingTeamName.text];
            
        } else {
            //Visitor team score changing
            newViewController.view.backgroundColor = self.visitorColor;
            currVisitorScore = newViewController.score;
            msgVisitor = [NSString stringWithString:self.visitingTeamName.text];
            msgHome = [NSString stringWithString:self.homeTeamName.text];

        }
    
    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{

    for (UIGestureRecognizer *gesture in pageViewController.view.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
		{
			return nil;
		}
    }
    
    //Cast the viewController as a ScoreViewController so we can act on its properties
    DefaultScoreViewController *oldViewController = (DefaultScoreViewController *)viewController;
    
    //Check the score, if it's 0, don't let the number get any lower
    if (oldViewController.score == 0) {
        return nil;
    }
    
    //Setup the new view controller with the new, higher score
    DefaultScoreViewController *newViewController = [self createViewControllersForScore:0
                                                                              withColor:self.visitorColor];
    
    newViewController.score = oldViewController.score - 1;
    
    //Check to see which view controller we're updating so the background color can be set correctly
    if (pageViewController == _homePageViewController) {
        //Home team score changing
        newViewController.view.backgroundColor = self.homeColor;
        currHomeScore = newViewController.score;
        msgVisitor = [NSString stringWithString:self.visitingTeamName.text];
        msgHome = [NSString stringWithString:self.homeTeamName.text];
        
    } else {
        //Visitor team score changing
        newViewController.view.backgroundColor = self.visitorColor;
        currVisitorScore = newViewController.score;
        msgVisitor = [NSString stringWithString:self.visitingTeamName.text];
        msgHome = [NSString stringWithString:self.homeTeamName.text];
    }
    
    return newViewController;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
