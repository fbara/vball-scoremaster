//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "VolleyBallViewController.h"
#import "DefaultScoreViewController.h"
#import "SettingsTableViewController.h"
#import "GBVersionTracking.h"
#import "GAIDictionaryBuilder.h"

//Constants for use when extending this to other sports
NSString *const EMBED_HOME = @"embedHome";
NSString *const EMBED_VISITOR = @"embedVisitor";
int currHomeScore = 0;
int currVisitorScore = 0;
int currSecondAction = 0;
int currFirstAction = 0;
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
    
    
    
    //Check if this is the first time the app has run.
    //If so, run tutorial.  If not, don't run turorial.
    if ([GBVersionTracking isFirstLaunchEver] || [GBVersionTracking isFirstLaunchForVersion]) {
        [self performSegueWithIdentifier:@"showTutorial" sender:self];
    }
    
    //Set the Google Analytics Screen name
    self.screenName = @"Scoring";
    
    //Initiaize all the UI elements
    [self initializeHomeScore:currHomeScore];
    [self initializeVisitorScore:currVisitorScore];
    [self resetGameAndNames];
    
    //Set Delegate's and DataSource's
    self.visitingTeamName.delegate = self;
    self.homeTeamName.delegate = self;
    self.visitorPageViewController.dataSource = self;
    self.visitorPageViewController.delegate = self;
    self.homePageViewController.dataSource = self;
    self.homePageViewController.delegate = self;
    
    //Create bar button items and add them to the navigation bar
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Settings"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(goToSettings)];
    UIImage *image = [UIImage imageNamed:@"Info44.png"];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]
                                   initWithImage:image
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(showInfoView)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:self
                                   action:nil];
    fixedSpace.width = 20.0f;
    NSArray *barButtonItems = @[settingsButton,fixedSpace, infoButton];
    self.navigationItem.rightBarButtonItems = barButtonItems;
    
    
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
//		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:homeSwipeGesture];
            
		}
        
//		if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:homeSwipeGesture];
		}
	}
    
	for (UIGestureRecognizer *gesture in _visitorPageViewController.view.gestureRecognizers)
	{
//		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:visitorSwipeGesture];
		}
        
//		if ([gesture isKindOfClass:[UITapGestureRecognizer class]])
		{
			[gesture requireGestureRecognizerToFail:visitorSwipeGesture];
		}
	}
    
    //Get the Action Names
    [self loadActionNames];

}

- (void)goToSettings
{
    //Segue to Settings View
    [self performSegueWithIdentifier:@"settingsView" sender:self];

}

- (void)showInfoView
{
    [self performSegueWithIdentifier:@"infoView" sender:self];
}

- (void)initializePastGames
{
    //There are 3 home & 3 visitor past scores that need to be reset to '00'
    for (UILabel *score in self.pastScoreCollection) {
        score.text = @"00";
        [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];
        score.textColor = [UIColor blackColor];
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

- (void)resetGameAndNames
{
    //Resets Game and Action Name values to 0
    self.gameNumber.text = @"1";
    self.rightActionNameNumber.text = @"0";
    self.leftActionNameNumber.text = @"0";
    currFirstAction = 0;
    currSecondAction = 0;
    currHomeScore = 0;
    currVisitorScore = 0;
    [self initializePastGames];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Update the scoreview's colors in case they were changed in Settings
    [self initializeVisitorScore:currVisitorScore];
    [self initializeHomeScore:currHomeScore];
    
    //Get the Action Names
    [self loadActionNames];
    
}

#pragma mark - UI Elements

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadActionNames
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempName;
    tempName = [defaults stringForKey:@"leftActionName"];
    
    if ([tempName length] < 1) {
        self.leftActionLabel.text = @"SPIKE";
    } else {
        self.leftActionLabel.text = [defaults stringForKey:@"leftActionName"];
    }
    
    tempName = [defaults stringForKey:@"rightActionName"];
    
    if ([tempName length] < 1) {
        self.rightActionLabel.text = @"ACE";
    } else {
        self.rightActionLabel.text = [defaults stringForKey:@"rightActionName"];
    }
}

#pragma mark - Google Analytics

- (void)logButtonPress:(UIButton *)button
{
    //Logs button presses, gets the title text of the button, and sends it
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Scoring"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:[button.titleLabel text]
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)logMessagesSent
{
    //Logs that a text message was sent
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Scoring"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"message"
                                                           label:@"message sent"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

#pragma mark - UIGestureRecognizer Delegate Method

// Force all gestures to be handled simultaneously.
//This will allow the Swipes and PageViewController's Pan/Tap gestures to coexsist and function correctly.
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UISwipeGestureRecognizers

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
    //Get the center of each past score label
    CGPoint targetHomeGame1 = self.visitGame1.center;
    CGPoint targetHomeGame2 = self.visitGame2.center;
    CGPoint targetHomeGame3 = self.visitGame3.center;
    CGPoint targetVisitGame1 = self.homeGame1.center;
    CGPoint targetVisitGame2 = self.homeGame2.center;
    CGPoint targetVisitGame3 = self.homeGame3.center;

    
    //Create the animation and swap positions of the score controllers
    [UIView animateWithDuration:0.7f
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         //Move the score containers
                         _homeTeamContainer.center = targetHomeCenter;
                         _homeTeamName.center = targetHomeNameCenter;
                         _vistingTeamContainer.center = targetVisitorCenter;
                         _visitingTeamName.center = targetVisitorNameCenter;
                         
                         //Now move the past scores
                         self.homeGame1.center = targetHomeGame1;
                         self.homeGame2.center = targetHomeGame2;
                         self.homeGame3.center = targetHomeGame3;
                         self.visitGame1.center = targetVisitGame1;
                         self.visitGame2.center = targetVisitGame2;
                         self.visitGame3.center = targetVisitGame3;
                        
                     }
                     completion:NULL];
}



#pragma mark - UILongPressGestureRecognizers
#pragma mark - Reset Numbers to 0

- (IBAction)sendInstantMessage:(UIButton *)sender
{
    //Log the button press for analytics
    [self logButtonPress:(UIButton *)sender];
    
    //Send a text message without changing the Action numbers
    [self sendSMS];
}

- (IBAction)leftActionLongPress:(UILongPressGestureRecognizer *)recognizer
{
    //On a long press, show popup menu with selections to reset the number to zero or not
    
    [self.rightActionNameNumber canBecomeFirstResponder];
    
    //Check if the number is not a zero
    if ([self.leftActionNameNumber.text isEqualToString:@"0"]) {
        //Equal to zero so don't show the popup menu
        return;
    } else {
        //Number is not a zero, show popup menu
        UIMenuItem *resetMenu = [[UIMenuItem alloc] initWithTitle:@"Reset to 0" action:@selector(resetTopToZero)];
        UIMenuItem *cancelMenu = [[UIMenuItem alloc] initWithTitle:@"Cancel" action:@selector(leaveNumberAsIs)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:resetMenu, cancelMenu, nil]];
        [menu setTargetRect:self.leftActionNameNumber.frame inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (IBAction)rightActionLongPress:(UILongPressGestureRecognizer *)recognizer
{
    //On a long press, show popup menu with selections to reset the number to zero or not
    
    [self.rightActionNameNumber canBecomeFirstResponder];
    
    //Check if the number is not a zero
    if ([self.rightActionNameNumber.text isEqualToString:@"0"]) {
        //Equal to zero so don't show the popup menu
        return;
    } else {
        //Number is not a zero, show popup menu
        UIMenuItem *resetMenu = [[UIMenuItem alloc] initWithTitle:@"Reset to 0" action:@selector(resetBottomToZero)];
        UIMenuItem *cancelMenu = [[UIMenuItem alloc] initWithTitle:@"Cancel" action:@selector(leaveNumberAsIs)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:resetMenu, cancelMenu, nil]];
        [menu setTargetRect:self.rightActionNameNumber.frame inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)resetTopToZero
{
    self.leftActionNameNumber.text = @"0";
}

- (void)resetBottomToZero
{
    self.rightActionNameNumber.text = @"0";
}

- (void)leaveNumberAsIs
{
    //Dummy method to allow UIMenuItems to be visible
}

- (BOOL)canBecomeFirstResponder { return YES; }

#pragma mark - Button Presses
/*!
 *  What happens when 'Game' number is touched
 */
- (IBAction)gamePressed:(UIButton *)sender
{
    //Log the button press for analytics
    [self logButtonPress:(UIButton *)sender];
    
    //Grab the game number
    int lableNum = [self.gameNumber.text intValue];
    //Update the past scores, set the winner in red text
    //For a tie, both get plain black
    switch (lableNum) {
        case 1:
            self.homeGame1.text = [NSString stringWithFormat:@"%d", currHomeScore];
            self.visitGame1.text = [NSString stringWithFormat:@"%d", currVisitorScore];
            if (currHomeScore > currVisitorScore) {
                self.homeGame1.textColor = [UIColor redColor];
                [self.homeGame1 setFont:[UIFont boldSystemFontOfSize:20]];
            } else if (currHomeScore < currVisitorScore) {
                self.visitGame1.textColor = [UIColor redColor];
                [self.visitGame1 setFont:[UIFont boldSystemFontOfSize:20]];
            } else {
                self.visitGame1.textColor = [UIColor blackColor];
                self.homeGame1.textColor = [UIColor blackColor];
            }
            break;
        case 2:
            self.homeGame2.text = [NSString stringWithFormat:@"%d", currHomeScore];
            self.visitGame2.text = [NSString stringWithFormat:@"%d", currVisitorScore];
            if (currHomeScore > currVisitorScore) {
                self.homeGame2.textColor = [UIColor redColor];
                [self.homeGame2 setFont:[UIFont boldSystemFontOfSize:20]];
            } else if (currHomeScore < currVisitorScore) {
                self.visitGame2.textColor = [UIColor redColor];
                [self.visitGame2 setFont:[UIFont boldSystemFontOfSize:20]];
            }else {
                self.visitGame2.textColor = [UIColor blackColor];
                self.homeGame2.textColor = [UIColor blackColor];
            }
            break;
        case 3:
            self.homeGame3.text = [NSString stringWithFormat:@"%d", currHomeScore];
            self.visitGame3.text = [NSString stringWithFormat:@"%d", currVisitorScore];
            if (currHomeScore > currVisitorScore) {
                self.homeGame3.textColor = [UIColor redColor];
                [self.homeGame3 setFont:[UIFont boldSystemFontOfSize:20]];
            } else if (currHomeScore < currVisitorScore) {
                self.visitGame3.textColor = [UIColor redColor];
                [self.visitGame3 setFont:[UIFont boldSystemFontOfSize:20]];
            } else {
                self.visitGame3.textColor = [UIColor blackColor];
                self.homeGame3.textColor = [UIColor blackColor];
            }
        default:
            break;
    }
    //Increase the game number by 1 but don't let it go more than 4
    lableNum = lableNum + 1;
    
    if (lableNum <= 4) {
        self.gameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
        //Reset the scores to start a new game
        [self initializeHomeScore:0];
        [self initializeVisitorScore:0];
        
    } else {
        self.gameNumber.text = [NSString stringWithFormat:@"%d", 0];
        //Reset the past game fonts back to default
        for (UILabel *score in self.pastScoreCollection) {
            score.text = @"00";
            [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];
            score.textColor = [UIColor blackColor];
        }
    }
    currVisitorScore = 0;
    currHomeScore = 0;
}

/*!
 *  What happens when right Action number is touched
 */
- (IBAction)rightActionPressed:(UIButton *)sender
{
    //Log the button press for analytics
    [self logButtonPress:(UIButton *)sender];
    
    //Get the number currently displayed for second Action Name and add 1
    int lableNum = [self.rightActionNameNumber.text intValue];
    if (lableNum == 99) {
        lableNum = 0;
    } else {
        lableNum = lableNum + 1;
    }
    self.rightActionNameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    currSecondAction = lableNum;
    
    //Send text message
    [self sendSMS];
}

/*!
 *  What happens when left Action number is touched
 */
- (IBAction)leftActionPressed:(UIButton *)sender
{
    //Log the button press for analytics
    [self logButtonPress:(UIButton *)sender];
    
    //Get current number and add 1
    int lableNum = [self.leftActionNameNumber.text intValue];
    if (lableNum == 99) {
        lableNum = 0;
    } else {
        lableNum = lableNum + 1;
    }
    self.leftActionNameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    currFirstAction = lableNum;
    
    //Send the text message
    [self sendSMS];
}

/*!
 *  What happens when 'New Match' button is touched
 */
- (IBAction)newMatch:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Match?", nil)
                                                        message:NSLocalizedString(@"Reset scores, action names, and start a new match?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", nil)
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [alert show];
}

#pragma mark - Text Messages & Alerts

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self initializeHomeScore:0];
        [self initializeVisitorScore:0];
        [self resetGameAndNames];
        [self initializePastGames];

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
            
            NSString *textMessage = [NSString stringWithFormat:@"%@ has %d %@'s and %d %@'s!\nThe score is now %@ %d - %@ %d.", playerName ,currSecondAction, self.rightActionLabel.text, currFirstAction, self.leftActionLabel.text, msgVisitor, currVisitorScore, msgHome, currHomeScore];
            [textComposer setRecipients:[NSArray arrayWithObjects:notificationNumber, nil]];
            
            [textComposer setBody:textMessage];
            [self presentViewController:textComposer
                               animated:YES
                             completion:nil];
            [self logMessagesSent];
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
            
        } else {
           //Visitor team score changing
            newViewController.view.backgroundColor = self.visitorColor;
        }
    
    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{

    //Cast the viewController as a ScoreViewController so we can act on its properties
    DefaultScoreViewController *oldViewController = (DefaultScoreViewController *)viewController;
    
    //Check the score, if it's 0, don't let the number get any lower
    if (oldViewController.score == 0) {
        return nil;
    }
    
    //Setup the new view controller with the new, higher score
    DefaultScoreViewController *newViewController = [self createViewControllersForScore:0
                                                                              withColor:[UIColor clearColor]];
    
    newViewController.score = oldViewController.score - 1;
    
    //Check to see which view controller we're updating so the background color can be set correctly
    if (pageViewController == _homePageViewController) {
       //Home team score changing
        newViewController.view.backgroundColor = self.homeColor;
       
    } else {
        //Visitor team score changing
        newViewController.view.backgroundColor = self.visitorColor;
    }
    
    return newViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    // If animation hasn't completed, exit; do not adjust score
	if (completed == NO)
	{
		return;
	}
    
	//	int previousScore = ((ScoreViewController*)previousViewControllers.firstObject).score;
	NSInteger currentScore = ((DefaultScoreViewController*)pageViewController.viewControllers.firstObject).score;
    
	if (pageViewController == _homePageViewController)
	{
		_homePageViewController.view.backgroundColor = self.homeColor;
        currHomeScore = (int)currentScore;
	}
	
	if (pageViewController == _visitorPageViewController)
	{
		_visitorPageViewController.view.backgroundColor = self.visitorColor;
        currVisitorScore = (int)currentScore;
	}
    
    msgVisitor = [NSString stringWithString:self.visitingTeamName.text];
    msgHome = [NSString stringWithString:self.homeTeamName.text];

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
