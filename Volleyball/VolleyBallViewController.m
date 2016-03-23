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
#import <GBVersionTracking/GBVersionTracking.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <ChameleonFramework/Chameleon.h>
#import <AppbotX/ABX.h>
#import <AppbotX/ABXNotificationView.h>
@import Social;
@import Accounts;
@import StoreKit;
@import UIKit;

NSString* const EMBED_HOME = @"embedHome";
NSString* const EMBED_VISITOR = @"embedVisitor";
int currHomeScore = 0;
int currVisitorScore = 0;
int currSecondAction = 0;
int currFirstAction = 0;
NSString* msgHome = @"HOME";
NSString* msgVisitor = @"VISITOR";
NSString* textMessage;
UIImage* screenImage;
static NSString* const kiTunesID = @"886670213";
// Score number font size for each device
CGFloat const ipadScoreFont = 220.0f;
CGFloat const iphoneScoreFont = 120.0f;
NSString* colorScheme;
NSString *socialMessage;
int totalPastGamesHome;
int totalPastGamesVisitor;

@interface VolleyBallViewController () {
    // Instance variable to store all products returned from iTunes Connect
    NSArray* _products;
}

@property (weak, atomic) UIPageViewController* homePageViewController;
@property (weak, atomic) UIPageViewController* visitorPageViewController;
@property (weak, nonatomic) NSURL* baralabsURL;
@property (strong, nonatomic) ABXPromptView* promptView;

@end

@implementation VolleyBallViewController

#pragma mark - Initialize Screen

// Called first, before the main view controller is loaded
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:EMBED_HOME]) {
        self.homePageViewController = segue.destinationViewController;
    }

    if ([segue.identifier isEqualToString:EMBED_VISITOR]) {
        self.visitorPageViewController = segue.destinationViewController;
    }
}

// Called second, after the segue's are setup
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set home URL for Twitter and Facebook messages
    self.baralabsURL = [NSURL URLWithString:@"www.baralabs.com"];

    // Check if this is the first time the app has run.
    // If so, run tutorial.  If not, don't run turorial.
    if ([GBVersionTracking isFirstLaunchEver] ||
        [GBVersionTracking isFirstLaunchForVersion]) {
        [self performSegueWithIdentifier:@"showTutorial" sender:self];
    }

    // Set the Google Analytics Screen name
    self.screenName = @"Scoring";

    [self resetGameAndNames];

    // Set Delegate's and DataSource's
    self.visitingTeamName.delegate = self;
    self.homeTeamName.delegate = self;
    self.visitorPageViewController.dataSource = self;
    self.visitorPageViewController.delegate = self;
    self.homePageViewController.dataSource = self;
    self.homePageViewController.delegate = self;

    // Create bar button item and add them to the navigation bar
    UIBarButtonItem* settingsButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(goToSettings:)];
    self.navigationItem.rightBarButtonItem = settingsButton;

    // Create Home swipe gesture and add it to the home container view.
    // Set this controller as the delegate to allow simultaneous gestures in the
    // PageViewController's container view
    UISwipeGestureRecognizer* homeSwipeGesture =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleSwipe:)];
    homeSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    homeSwipeGesture.delegate = self;
    [_homeTeamContainer addGestureRecognizer:homeSwipeGesture];

    // Create the same thing for the visitor team container
    UISwipeGestureRecognizer* visitorSwipeGesture =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleSwipe:)];
    visitorSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    visitorSwipeGesture.delegate = self;
    [_vistingTeamContainer addGestureRecognizer:visitorSwipeGesture];

    /*! Loop through all the gesture recognizers on each of the pageview
   * controllers and when you locate either the tap or pan recognizers, set them to require
   * the appropriate swipe gesture to fail before they'll recognize their gesture.
   */

    for (UIGestureRecognizer *gesture in _homePageViewController.view
             .gestureRecognizers) {
        {
            [gesture requireGestureRecognizerToFail:homeSwipeGesture];
        }

        {
            [gesture requireGestureRecognizerToFail:homeSwipeGesture];
        }
    }

    for (UIGestureRecognizer *gesture in _visitorPageViewController.view
             .gestureRecognizers) {
        {
            [gesture requireGestureRecognizerToFail:visitorSwipeGesture];
        }

        {
            [gesture requireGestureRecognizerToFail:visitorSwipeGesture];
        }
    }

    // Get the Action Names
    [self loadActionNames];
    
    //Setup the AppbotX prompt for Reviews
    if (![ABXPromptView hasHadInteractionForCurrentVersion]) {
        if ((([[NSUserDefaults standardUserDefaults] integerForKey:@"launchNumber"]) == 10) &&
            [[[NSUserDefaults standardUserDefaults] objectForKey:@"showPrompt"]
                isEqualToString:@"Yes"]) {
            // Show the Prompt view on the 10th time the user has launched the app
	self.promptView = [[ABXPromptView alloc]
                initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 200, CGRectGetWidth(self.view.bounds), 100)];
            self.promptView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            self.promptView.backgroundColor = FlatYellow;
            self.promptView.delegate = self;
            [self.view addSubview:self.promptView];
            [[NSUserDefaults standardUserDefaults] setObject:@"No"
                                                      forKey:@"showPrompt"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    //Reset total game counts
    totalPastGamesHome = 0;
    totalPastGamesVisitor = 0;
    
    [self checkForActiveNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


    // Update the scoreview's colors in case they were changed in Settings
    // Initiaize all the UI elements depending on the device (font=188/118)
    if (IS_IPAD()) {
        [self initializeHomeScore:currHomeScore fontSize:ipadScoreFont];
        [self initializeVisitorScore:currVisitorScore fontSize:ipadScoreFont];
    } else {
        [self initializeHomeScore:currHomeScore fontSize:iphoneScoreFont];
        [self initializeVisitorScore:currVisitorScore fontSize:iphoneScoreFont];
    }

    // Get the Action Names
    [self loadActionNames];

    // Format the circular button around the VBall
    [self formatVBallButton];

    // Format the window background color
    [self windowBackgroundColor];

    // Show or hide the social buttons depending on the IAP
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"purchasedSocial"]) {
        self.mainPageTwitterButton.hidden = FALSE;
        self.mainPageFacebookButton.hidden = FALSE;

    } else {
        self.mainPageTwitterButton.hidden = TRUE;
        self.mainPageFacebookButton.hidden = TRUE;
    }
    
    [self enableSocialButtons];


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Register for notifications from SettingsTableViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:@"SettingsDone"
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"SettingsDone"
                                                  object:nil];
    //Remove observer for Action Names
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateActionNames"
                                                  object:nil];

    [super viewWillDisappear:animated];
}

- (IBAction)goToSettings:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"settingsView" sender:self];
}

- (void)initializePastGames
{
    // There are 4 home & 4 visitor past scores that need to be reset to '0'
    for (UILabel* score in self.pastScoreCollection) {
        score.text = @"0";
        if (IS_IPAD()) {
            [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:30]];
        } else {
            [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];
        }
        // Need to check what color background is being used.
        if ([colorScheme isEqualToString:@"Dark"]) {
            // Dark background so change color to yellow
            score.textColor = FlatYellow;
        } else if ([colorScheme isEqualToString:@"Colorful"]) {
            // Colorful background so change color to plum
            score.textColor = FlatPlum;
        } else {
            // Regular background
            score.textColor = FlatBlackDark;
        }
    }
    
    //Reset the total team wins game count
    totalPastGamesVisitor = 0;
    totalPastGamesHome = 0;
}

- (void)initializeHomeScore:(int)score fontSize:(CGFloat)scoreSize
{
    self.homeColor = [self colorHomeScoreView];
    DefaultScoreViewController* homeScoreViewController =
        [self createViewControllersForScore:score
                                  withColor:self.homeColor
                                   fontSize:scoreSize];
    self.homePageViewController.dataSource = self;
    [self.homePageViewController
        setViewControllers:@[ homeScoreViewController ]
                 direction:UIPageViewControllerNavigationDirectionForward
                  animated:NO
                completion:nil];
}

- (void)initializeVisitorScore:(int)score fontSize:(CGFloat)scoreSize
{
    self.visitorColor = [self colorVisitorScoreView];
    DefaultScoreViewController* visitorScoreViewController =
        [self createViewControllersForScore:score
                                  withColor:self.visitorColor
                                   fontSize:scoreSize];
    self.visitorPageViewController.dataSource = self;
    [self.visitorPageViewController
        setViewControllers:@[ visitorScoreViewController ]
                 direction:UIPageViewControllerNavigationDirectionForward
                  animated:NO
                completion:nil];
}

- (DefaultScoreViewController*)createViewControllersForScore:(int)score
                                                   withColor:(UIColor*)color
                                                    fontSize:
                                                        (CGFloat)scoreSize
{
    // Create a new scoreViewController and initialize it with 'nil',
    // that will create one with a xib of the same name
    DefaultScoreViewController* newScoreViewController =
        [[DefaultScoreViewController alloc] initWithNibName:nil bundle:nil];
    // Set the properties of the score view
    newScoreViewController.view.backgroundColor = color;
    newScoreViewController.score = score;
    [newScoreViewController setScoreNumberSize:scoreSize];

    return newScoreViewController;
}

#pragma mark - Color Settings

- (UIColor*)colorHomeScoreView
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    // Get home team background colors
    UIColor* colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData* theHomeData = [defaults dataForKey:@"homeTeamColor"];
    if (theHomeData != nil) {
        colorHome = (UIColor*)[NSKeyedUnarchiver unarchiveObjectWithData:theHomeData];
    } else {
        colorHome = [UIColor blueColor];
    }

    NSString* color = [defaults stringForKey:@"colorSettings"];

    if ([color isEqualToString:@"Complementary"] ||
        [color isEqualToString:@"Dark"]) {
        self.homeTeamName.backgroundColor = ComplementaryFlatColor(colorHome);
        // Set the team name text color to a contrasting color
        self.homeTeamName.textColor = ContrastColor(self.homeTeamName.backgroundColor, TRUE);
    } else {
        self.homeTeamName.backgroundColor = [UIColor whiteColor];
        self.homeTeamName.textColor = [UIColor blackColor];
    }
    return colorHome;
}

- (UIColor*)colorVisitorScoreView
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    // Get visiting team background colors
    UIColor* colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData* theVisitorData = [defaults dataForKey:@"visitorTeamColor"];
    if (theVisitorData != nil) {
        colorVisitor = (UIColor*)[NSKeyedUnarchiver unarchiveObjectWithData:theVisitorData];
    } else {
        colorVisitor = [UIColor orangeColor];
    }

    NSString* color = [defaults stringForKey:@"colorSettings"];

    if ([color isEqualToString:@"Complementary"] ||
        [color isEqualToString:@"Dark"]) {
        self.visitingTeamName.backgroundColor = ComplementaryFlatColor(colorVisitor);
        self.visitingTeamName.textColor = ContrastColor(self.visitingTeamName.backgroundColor, TRUE);

    } else {
        self.visitingTeamName.backgroundColor = [UIColor whiteColor];
        self.visitingTeamName.textColor = [UIColor blackColor];
    }

    return colorVisitor;
}

/*!
 *  Sets the color of the main window based on user preference
 */
- (void)windowBackgroundColor
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([[defaults objectForKey:@"colorSettings"]
            isEqualToString:@"Complementary"]) {
        colorScheme = @"Colorful";
        self.view.backgroundColor = FlatSand;
        self.navigationController.navigationBar.barTintColor = FlatSkyBlue;
        self.navigationController.navigationBar.tintColor = ContrastColor(FlatSkyBlue, TRUE);
        self.navigationController.navigationBar.titleTextAttributes =
            @{ NSForegroundColorAttributeName : ContrastColor(FlatSkyBlue, TRUE) };
        self.rightActionNameNumber.textColor = FlatMintDark;
        self.leftActionNameNumber.textColor = FlatMintDark;
        self.gameNumber.textColor = ContrastColor(self.view.backgroundColor, TRUE);
        for (UILabel* lable in self.pastScoreCollection) {
            // First, check if any of the past score fonts are red
            // If so, put them back to red after the recolor
            if (![lable.text isEqualToString:@"0"]) {
                lable.textColor = FlatRed;
            } else {
                lable.textColor = FlatPlum;
            }
        }
        [self changePastScoreColors:FlatRed loser:FlatPlum];
        
    } else if ([[defaults objectForKey:@"colorSettings"]
                   isEqualToString:@"Dark"]) {
        colorScheme = @"Dark";
        self.view.backgroundColor = FlatBlackDark;
        self.navigationController.navigationBar.barTintColor = FlatBlackDark;
        self.navigationController.navigationBar.tintColor = ContrastColor(FlatBlack, TRUE);
        self.navigationController.navigationBar.titleTextAttributes = @{
            NSForegroundColorAttributeName : ContrastColor(FlatBlackDark, TRUE)
        };
        self.rightActionNameNumber.textColor = FlatGreen;
        self.leftActionNameNumber.textColor = FlatGreen;
        self.gameNumber.textColor = FlatMint;
        for (UILabel* lable in self.pastScoreCollection) {
            if (![lable.text isEqualToString:@"0"]) {
                lable.textColor = FlatRed;
            } else {
                lable.textColor = FlatYellow;
            }
        }
        [self changePastScoreColors:FlatRed loser:FlatYellow];

    } else {
        colorScheme = @"Regular";
        self.view.backgroundColor = FlatWhite;
        self.navigationController.navigationBar.barTintColor = FlatNavyBlue;
        self.navigationController.navigationBar.tintColor = ContrastColor(FlatNavyBlue, TRUE);
        self.navigationController.navigationBar.titleTextAttributes = @{
            NSForegroundColorAttributeName : ContrastColor(FlatNavyBlue, TRUE)
        };
        self.rightActionNameNumber.textColor = FlatBlackDark;
        self.leftActionNameNumber.textColor = FlatBlackDark;
        self.gameNumber.textColor = FlatBlackDark;
        for (UILabel* lable in self.pastScoreCollection) {
            if (![lable.text isEqualToString:@"0"]) {
                lable.textColor = FlatRed;
            } else {
                lable.textColor = FlatBlack;
            }
        }
        [self changePastScoreColors:FlatRed loser:FlatBlack];

    }
}

- (void)changePastScoreColors:(UIColor *)winTeam loser:(UIColor *)loseTeam
{
    //After the main screen changes colors, this evaluates all the past scores to determine
    //the winner & loser, changing its color appropriately.
    
    if ([self.homeGame1.text intValue] > [self.visitGame1.text intValue]) {
        self.homeGame1.textColor = winTeam;
        self.visitGame1.textColor = loseTeam;
    } else if ([self.homeGame1.text intValue] < [self.visitGame1.text intValue]) {
        self.homeGame1.textColor = loseTeam;
        self.visitGame1.textColor = winTeam;
    }
    
    if ([self.homeGame2.text intValue] > [self.visitGame2.text intValue]) {
        self.homeGame2.textColor = winTeam;
        self.visitGame2.textColor = loseTeam;
    } else if ([self.homeGame2.text intValue] < [self.visitGame2.text intValue]) {
        self.homeGame2.textColor = loseTeam;
        self.visitGame2.textColor = winTeam;
    }
    
    if ([self.homeGame3.text intValue] > [self.visitGame3.text intValue]) {
        self.homeGame3.textColor = winTeam;
        self.visitGame3.textColor = loseTeam;
    } else if ([self.homeGame3.text intValue] < [self.visitGame3.text intValue]) {
        self.homeGame3.textColor = loseTeam;
        self.visitGame3.textColor = winTeam;
    }
    
    if ([self.homeGame4.text intValue] > [self.visitGame4.text intValue]) {
        self.homeGame4.textColor = winTeam;
        self.visitGame4.textColor = loseTeam;
    } else if ([self.homeGame4.text intValue] < [self.visitGame4.text intValue]) {
        self.homeGame4.textColor = loseTeam;
        self.visitGame4.textColor = winTeam;
    }
}

- (void)resetGameAndNames
{
    // Resets Game, Team Names, and Action Name values to 0
    self.gameNumber.text = @"1";
    self.rightActionNameNumber.text = @"0";
    self.leftActionNameNumber.text = @"0";
    currFirstAction = 0;
    currSecondAction = 0;
    currHomeScore = 0;
    currVisitorScore = 0;
	self.homeTeamName.text = @"";
	self.visitingTeamName.text = @"";
    totalPastGamesVisitor = 0;
    totalPastGamesHome = 0;
	
    [self initializePastGames];
}

#pragma mark - UI Elements

- (void)loadActionNames
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    NSString* tempName;
    tempName = [defaults stringForKey:@"leftActionName"];

    if ([tempName length] < 1) {
        self.leftActionLabel.text = @"Not Selected";
    } else {
        self.leftActionLabel.text = [defaults stringForKey:@"leftActionName"];
    }

    tempName = [defaults stringForKey:@"rightActionName"];

    if ([tempName length] < 1) {
        self.rightActionLabel.text = @"Not Selected";
    } else {
        self.rightActionLabel.text = [defaults stringForKey:@"rightActionName"];
    }
}

#pragma mark - Google Analytics

/*!
 *  @author Me, 03-21-16 16:03
 *
 *  Determines if the user has allowed the use of analytics.
 *
 *  @return BOOL Returns TRUE if analytics are allowed and FALSE if not.
 */
- (BOOL)canSendAnalytics {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *analytics = [defaults stringForKey:@"analyticsChoice"];
    if ([analytics isEqualToString:@"Opt in"]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)logButtonPress:(UIButton*)button
{
    // Logs button presses, gets the title text of the button, and sends it
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName value:@"Scoring"];
    [tracker send:[[GAIDictionaryBuilder
                      createEventWithCategory:@"UX"
                                       action:@"touch"
                                        label:[button.titleLabel text]
                                        value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)logMessagesSent:(NSString *)type
{
    // Logs that a text message was sent
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName value:@"Scoring"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"message"
                                                           label:type
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)logTwitterSent
{
    // Logs that a Twitter message was sent
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName value:@"Twitter"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"social"
                                                           label:@"twitter sent"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)logFacebookSent
{
    // Logs that a Twitter message was sent
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName value:@"Facebook"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"social"
                                                           label:@"facebook sent"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

#pragma mark - UIGestureRecognizer Delegate Method

// Force all gestures to be handled simultaneously.
// This will allow the Swipes and PageViewController's Pan/Tap gestures to
// coexsist and function correctly.
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UISwipeGestureRecognizers

/*!
 * @discussion Handle the swipe gesture to swap positions of scoreviews
 * @param recognizer UIGestureRecognizer to indicate what type of gesture is
 * being sent
 */
- (IBAction)handleSwipe:(UISwipeGestureRecognizer*)recognizer
{
    // Get the center of each score view container
    CGPoint targetHomeCenter = _vistingTeamContainer.center;
    CGPoint targetVisitorCenter = _homeTeamContainer.center;
    CGPoint targetHomeNameCenter = _visitingTeamName.center;
    CGPoint targetVisitorNameCenter = _homeTeamName.center;
    // Get the center of each past score label
    CGPoint targetHomeGame1 = self.visitGame1.center;
    CGPoint targetHomeGame2 = self.visitGame2.center;
    CGPoint targetHomeGame3 = self.visitGame3.center;
    CGPoint targetHomeGame4 = self.visitGame4.center;
    CGPoint targetVisitGame1 = self.homeGame1.center;
    CGPoint targetVisitGame2 = self.homeGame2.center;
    CGPoint targetVisitGame3 = self.homeGame3.center;
    CGPoint targetVisitGame4 = self.homeGame4.center;

    // Create the animation and swap positions of the score controllers
    [UIView animateWithDuration:0.7f // 0.7
                          delay:0.0f
         usingSpringWithDamping:0.8f // 0.8
          initialSpringVelocity:0.5f // 0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                       // Move the score containers
                       _homeTeamContainer.center = targetHomeCenter;
                       _homeTeamName.center = targetHomeNameCenter;
                       _vistingTeamContainer.center = targetVisitorCenter;
                       _visitingTeamName.center = targetVisitorNameCenter;

                       // Now move the past scores
                       self.homeGame1.center = targetHomeGame1;
                       self.homeGame2.center = targetHomeGame2;
                       self.homeGame3.center = targetHomeGame3;
                       self.homeGame4.center = targetHomeGame4;
                       self.visitGame1.center = targetVisitGame1;
                       self.visitGame2.center = targetVisitGame2;
                       self.visitGame3.center = targetVisitGame3;
                       self.visitGame4.center = targetVisitGame4;
                     }
                     completion:NULL];
}

#pragma mark - UILongPressGestureRecognizers
#pragma mark - Reset Action Numbers to 0

- (IBAction)sendInstantMessage:(UIButton*)sender
{
    // Log the button press for analytics
    if ([self canSendAnalytics]) {
        [self logButtonPress:(UIButton*)sender];
    }

    // Send a text message without changing the Action numbers
    [self sendSMS];
}

- (IBAction)leftActionLongPress:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Check if the number is not a zero
        if ([self.leftActionNameNumber.text isEqualToString:@"0"]) {
            // Equal to zero so don't show the popup menu
            return;
        } else {
            // Number is not a zero, show popup menu
            UIMenuItem* resetMenu = [[UIMenuItem alloc] initWithTitle:@"Reset to 0"
                                                               action:@selector(resetLeftToZero)];
            UIMenuItem* cancelMenu = [[UIMenuItem alloc] initWithTitle:@"Cancel"
                                                                action:@selector(leaveNumberAsIs)];

            UIMenuController* menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:[NSArray arrayWithObjects:resetMenu, cancelMenu, nil]];
            [self becomeFirstResponder];
            [menu setTargetRect:self.leftActionNameNumber.frame inView:self.view];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}

- (IBAction)rightActionLongPress:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
            // Check if the number is not a zero
        if ([self.rightActionNameNumber.text isEqualToString:@"0"]) {
            // Equal to zero so don't show the popup menu
            return;
        } else {
            // Number is not a zero, show popup menu
            UIMenuItem* resetMenu = [[UIMenuItem alloc] initWithTitle:@"Reset to 0"
                                                               action:@selector(resetRightToZero)];
            UIMenuItem* cancelMenu = [[UIMenuItem alloc] initWithTitle:@"Cancel"
                                                                action:@selector(leaveNumberAsIs)];

            UIMenuController* menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:[NSArray arrayWithObjects:resetMenu,cancelMenu, nil]];
            [self becomeFirstResponder];
            [menu setTargetRect:self.rightActionNameNumber.frame inView:self.view];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}

- (void)resetLeftToZero
{
    self.leftActionNameNumber.text = @"0";
}

- (void)resetRightToZero
{
    self.rightActionNameNumber.text = @"0";
}

- (void)leaveNumberAsIs
{
    // Dummy method to allow UIMenuItems to be visible
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Button Presses

// Format the VBall button
- (void)formatVBallButton
{
    // If running on iPad, use these settings
    if (IS_IPAD()) {
		//I commented out the next 2 lines because it was causing the vball image to shrink
        //self.sendMessageImage.frame = CGRectMake(472.0, 277.0, 160.0, 160.0);
        // self.sendMessageImage.layer.cornerRadius = 40;
    } else {
        // Running on iPhone or iPod
        self.sendMessageImage.frame = CGRectMake(238.0, 149.0, 87.0, 87.0);
        // self.sendMessageImage.layer.cornerRadius = 40;
    }
    self.sendMessageImage.layer.cornerRadius = self.sendMessageImage.frame.size.width / 2.0f;
    self.sendMessageImage.clipsToBounds = YES;
    self.sendMessageImage.layer.masksToBounds = YES;
}

/*!
 *  What happens when 'Game' number is touched
 */
- (IBAction)gamePressed:(UIButton*)sender
{
    // Log the button press for analytics
    if ([self canSendAnalytics]) {
        [self logButtonPress:(UIButton*)sender];
    }

    // Grab the game number
    int lableNum = [self.gameNumber.text intValue];
    // Update the past scores, set the winner in red text
    // For a tie, both get plain black
    switch (lableNum) {
    case 1:
        self.homeGame1.text = [NSString stringWithFormat:@"%d", currHomeScore];
        self.visitGame1.text = [NSString stringWithFormat:@"%d", currVisitorScore];
        if (currHomeScore > currVisitorScore) {
            self.homeGame1.textColor = [UIColor redColor];
            totalPastGamesHome = totalPastGamesHome + 1;
            if (IS_IPAD()) {
                [self.homeGame1 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.homeGame1 setFont:[UIFont boldSystemFontOfSize:20]];
            }

        } else if (currHomeScore < currVisitorScore) {
            self.visitGame1.textColor = [UIColor redColor];
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame1 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.visitGame1 setFont:[UIFont boldSystemFontOfSize:20]];
            }

        } else {
            self.visitGame1.textColor = FlatGray;
            self.homeGame1.textColor = FlatGray;
        }
        break;
    case 2:
        self.homeGame2.text = [NSString stringWithFormat:@"%d", currHomeScore];
        self.visitGame2.text = [NSString stringWithFormat:@"%d", currVisitorScore];
        if (currHomeScore > currVisitorScore) {
            self.homeGame2.textColor = FlatRed;
            totalPastGamesHome = totalPastGamesHome + 1;
            if (IS_IPAD()) {
                [self.homeGame2 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.homeGame2 setFont:[UIFont boldSystemFontOfSize:20]];
            }
        } else if (currHomeScore < currVisitorScore) {
            self.visitGame2.textColor = FlatRed;
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame2 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.visitGame2 setFont:[UIFont boldSystemFontOfSize:20]];
            }

        } else {
            self.visitGame2.textColor = FlatGray;
            self.homeGame2.textColor = FlatGray;
        }
        break;
    case 3:
        self.homeGame3.text = [NSString stringWithFormat:@"%d", currHomeScore];
        self.visitGame3.text = [NSString stringWithFormat:@"%d", currVisitorScore];
        if (currHomeScore > currVisitorScore) {
            self.homeGame3.textColor = FlatRed;
            totalPastGamesHome = totalPastGamesHome + 1;
            if (IS_IPAD()) {
                [self.homeGame3 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.homeGame3 setFont:[UIFont boldSystemFontOfSize:20]];
            }
        } else if (currHomeScore < currVisitorScore) {
            self.visitGame3.textColor = FlatRed;
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame3 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.visitGame3 setFont:[UIFont boldSystemFontOfSize:20]];
            }
        } else {
            self.visitGame3.textColor = FlatGray;
            self.homeGame3.textColor = FlatGray;
        }
        break;
    case 4:
        self.homeGame4.text = [NSString stringWithFormat:@"%d", currHomeScore];
        self.visitGame4.text = [NSString stringWithFormat:@"%d", currVisitorScore];
        if (currHomeScore > currVisitorScore) {
            self.homeGame4.textColor = FlatRed;
            totalPastGamesHome = totalPastGamesHome + 1;
            if (IS_IPAD()) {
                [self.homeGame4 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.homeGame4 setFont:[UIFont boldSystemFontOfSize:20]];
            }
        } else if (currHomeScore < currVisitorScore) {
            self.visitGame4.textColor = FlatRed;
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame4 setFont:[UIFont boldSystemFontOfSize:30]];
            } else {
                [self.visitGame4 setFont:[UIFont boldSystemFontOfSize:20]];
            }
        } else {
            self.visitGame4.textColor = FlatGray;
            self.homeGame4.textColor = FlatGray;
        }
        break;
    default:
        break;
    }
    // Increase the game number by 1 but don't let it go more than 5
    lableNum = lableNum + 1;

    if (lableNum <= 5) {
        self.gameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
        // Reset the scores to start a new game
        if (IS_IPAD()) {
            [self initializeHomeScore:00 fontSize:188];
            [self initializeVisitorScore:00 fontSize:188];
        } else {
            [self initializeHomeScore:00 fontSize:118];
            [self initializeVisitorScore:00 fontSize:118];
        }
    } else {
        self.gameNumber.text = [NSString stringWithFormat:@"%d", 1];
        // Reset the past game fonts back to default
        for (UILabel* score in self.pastScoreCollection) {
            score.text = @"0";
            if (IS_IPAD()) {
                [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:30]];
            } else {
                [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];
            }
        }
        [self startNewMatch];
    }
    currHomeScore = 0;
    currVisitorScore = 0;
}

/*!
 *  What happens when right Action number is touched
 */
- (IBAction)rightActionPressed:(UIButton*)sender
{
    // Log the button press for analytics
    if ([self canSendAnalytics]) {
        [self logButtonPress:(UIButton*)sender];
    }

    // Get the number currently displayed for right Action Name and add 1
    int lableNum = [self.rightActionNameNumber.text intValue];
    if (lableNum == 99) {
        lableNum = 0;
    } else {
        lableNum = lableNum + 1;
    }

// TODO Remove??
    // Keep track of the number for this action in case the user comes back to it
    // during this match
    //[defaults setInteger:lableNum forKey:self.rightActionLabel.text];

    self.rightActionNameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    currSecondAction = lableNum;

    // Send text message
    [self sendSMS];
}

/*!
 *  What happens when left Action number is touched
 */
- (IBAction)leftActionPressed:(UIButton*)sender
{
    // Log the button press for analytics
    if ([self canSendAnalytics]) {
        [self logButtonPress:(UIButton*)sender];
    }

    // Get current number and add 1
    int lableNum = [self.leftActionNameNumber.text intValue];
    if (lableNum == 99) {
        lableNum = 0;
    } else {
        lableNum = lableNum + 1;
    }

// TODO Remove??
    // Keep track of the number for this action in case the user comes back to it
    // during this match
    //[defaults setInteger:lableNum forKey:self.leftActionLabel.text];

    self.leftActionNameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    currFirstAction = lableNum;

    // Send the text message
    [self sendSMS];
}

/*!
 *  What happens when 'New Match' button is touched
 */
- (IBAction)newMatch:(UIBarButtonItem*)sender
{
#define TAG_MATCH 1

    UIAlertView* alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"New Match?", nil)
                  message:
                      NSLocalizedString(
                          @"Reset team names, scores, action names, and start a new match?",
                          nil)
                 delegate:self
        cancelButtonTitle:NSLocalizedString(@"No", nil)
        otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alert.tag = TAG_MATCH;
    [alert show];
}

- (void)startNewMatch
{
    // Initiaize all the UI elements, depending on the device, for the start
    // of a new match.
    if (IS_IPAD()) {
        [self initializeHomeScore:0 fontSize:188];
        [self initializeVisitorScore:0 fontSize:188];
    } else {
        [self initializeHomeScore:0 fontSize:118];
        [self initializeVisitorScore:0 fontSize:118];
    }

    [self resetGameAndNames];
    [self initializePastGames];
}

#pragma mark - Screen Image

/*!
 *  Takes a snapshot of the screen with the scores, prior
 *  to when the message or social screens take over the view
 *
 *  @return UIImage of the screen
 */
- (UIImage*)getScreenImage
{
    // Iterates thru every view on the screen, capturing and assemblying them to
    // form an image
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != &UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow* window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] ||
            [window screen] == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(
                context, -[window bounds].size.width * [[window layer] anchorPoint].x,
                -[window bounds].size.height * [[window layer] anchorPoint].y);

            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];

            // Restore the context
            CGContextRestoreGState(context);
        }
    }

    // Retrieve the screenshot image
    screenImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return screenImage;
}

#pragma mark - Social Accounts

- (void)enableSocialButtons
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([[defaults stringForKey:@"enableTwitter"] isEqualToString:@"On"]) {
        self.mainPageTwitterButton.enabled = TRUE;
    } else {
        self.mainPageTwitterButton.enabled = FALSE;
    }

    if ([[defaults stringForKey:@"enableFacebook"] isEqualToString:@"On"]) {
        self.mainPageFacebookButton.enabled = TRUE;
    } else {
        self.mainPageFacebookButton.enabled = FALSE;
    }
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (IBAction)sendTwitter:(UIButton*)sender;
{
    // Check if text messages should be sent
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([[defaults stringForKey:@"enableTwitter"] isEqualToString:@"On"]) {
        if ([self userHasAccessToTwitter]) {
            SLComposeViewController* twitterController = [SLComposeViewController
                composeViewControllerForServiceType:SLServiceTypeTwitter];

            NSString* newMessage, *tempStr1, *tempStr2;
            if ([[self teamOrPlayer] isEqualToString:@"Player"]) {
                tempStr1 = [self createPlayerMessageToSend];
                tempStr2 = @"\n#vballscoremaster";
            } else if ([[self teamOrPlayer] isEqualToString:@"Team"]) {
                tempStr1 = [self createTeamMessageToSend];
                tempStr2 = @"\n#vballscoremaster";
            } else {
                tempStr1 = [self createBlankMessageToSend];
                tempStr2 = @"";
            }
            
            newMessage = [tempStr1 stringByAppendingString:tempStr2];
            socialMessage = newMessage;

            [twitterController setInitialText:newMessage];
            [twitterController addImage:[self getScreenImage]];
            twitterController.completionHandler = ^(SLComposeViewControllerResult result) {
                          switch (result) {
                          case SLComposeViewControllerResultCancelled:
                            NSLog(@"Twitter post cancelled");
                            break;
                          case SLComposeViewControllerResultDone:
                              if ([self canSendAnalytics]) {
                                 [self logTwitterSent];
                              }
                            break;
                          default:
                            break;
                          }
                            };

            // Show Twitter screen
            [self presentViewController:twitterController
                               animated:YES
                             completion:nil];

            // Clear screen shot from memory
            screenImage = nil;

            // Log the button press for analytics
            if ([self canSendAnalytics]) {
                [self logButtonPress:(UIButton*)sender];
            }
        } else {
            // User either doesn't have Twitter or denied our access
            UIAlertView* alert = [[UIAlertView alloc]
                    initWithTitle:@"Can't access Twitter"
                          message:@"Either you don't have a Twitter account or this "
                          @"app has been denied access to your Twitter " @"account."
                         delegate:nil
                cancelButtonTitle:@"Ok"
                otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (BOOL)userHasAccessToFacebook
{
    return
        [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}

- (IBAction)sendFacebook:(UIButton*)sender
{
    // Check if text messages should be sent
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    // Check if user enabled sending by facebook
    if ([[defaults stringForKey:@"enableFacebook"] isEqualToString:@"On"]) {
        // Check if user has setup facebook on the device
        if ([self userHasAccessToFacebook]) {
            SLComposeViewController* facebookController = [SLComposeViewController
                composeViewControllerForServiceType:SLServiceTypeFacebook];

            NSString* newMessage, *tempStr1, *tempStr2;
            if ([[self teamOrPlayer] isEqualToString:@"Player"]) {
                tempStr1 = [self createPlayerMessageToSend];
                tempStr2 = @"\n#vballscoremaster";
            } else if ([[self teamOrPlayer] isEqualToString:@"Team"]) {
                tempStr1 = [self createTeamMessageToSend];
                tempStr2 = @"\n#vballscoremaster";
            } else {
                tempStr1 = [self createBlankMessageToSend];
                tempStr2 = @"";
            }
            
            newMessage = [tempStr1 stringByAppendingString:tempStr2];

            [facebookController setInitialText:newMessage];
            [facebookController addImage:[self getScreenImage]];
            [facebookController
                setCompletionHandler:^(SLComposeViewControllerResult result) {
              switch (result) {
              case SLComposeViewControllerResultCancelled:
                NSLog(@"Facebook post cancelled");
                break;
              case SLComposeViewControllerResultDone:
                  if ([self canSendAnalytics]) {
                      [self logFacebookSent];
                  }
              default:
                break;
              }
                }];

            // Show Facebook screen
            [self presentViewController:facebookController
                               animated:YES
                             completion:nil];

            // Clear screen shot from memory
            screenImage = nil;

            // Log the button press for analytics
            if ([self canSendAnalytics]) {
                [self logButtonPress:(UIButton*)sender];
            }
            
        } else {
            // User either doesn't have Facebook or denied our access
            UIAlertView* alert = [[UIAlertView alloc]
                    initWithTitle:@"Can't access Facebook"
                          message:@"Either you don't have a Facebook account or this "
                          @"app has been denied access to your Facebook " @"account."
                         delegate:nil
                cancelButtonTitle:@"Ok"
                otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - AppbotX

- (void)checkForActiveNotification {
    [ABXNotification fetchActive:^(NSArray *notifications, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        if (responseCode == ABXResponseCodeSuccess) {
            if (notifications.count > 0) {
                ABXNotification *notification = [notifications firstObject];
                BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstTimeEver"];
                NSInteger firstThisVer = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchNumber"];
                if (![notification hasSeen]) {
                    if (firstTime || (firstThisVer == 1)) {
                        return;
                    } else {
                        //Show the view
                        [ABXNotificationView show:notification.message
                                       actionText:notification.actionLabel
                                  backgroundColor:FlatBlueDark
                                        textColor:[UIColor whiteColor]
                                      buttonColor:[UIColor redColor]
                                     inController:self.navigationController
                                      actionBlock:^(ABXNotificationView *view) {
                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notification.actionUrl]];
                                      } dismissBlock:^(ABXNotificationView *view) {
                                          //Mark alert as being seen so it's not shown again
                                          [notification markAsSeen];
                                      }];

                        return;
                    }
                }
            }
        }
        
    }];
}

- (void)appbotPromptForReview
{
    [ABXAppStore openAppStoreReviewForApp:kiTunesID];
    self.promptView.hidden = YES;
}

- (void)appbotPromptForFeedback
{
    [ABXFeedbackViewController showFromController:self placeholder:nil];
    self.promptView.hidden = YES;
}

- (void)appbotPromptClose
{
    self.promptView.hidden = YES;
    // self.mainPageFacebookButton.hidden = FALSE;
    // self.mainPageTwitterButton.hidden = FALSE;
}

#pragma mark - Text Messages & Alerts

- (void)messageComposeViewController: (MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*!
 *  AlertView to be shown only when New Match? is touched
 *
 *  @param alertView   What to do if the user wants to start a new match or not.
 *  @param buttonIndex The button the user touched to start a new match or not.
 */
- (void)alertView:(UIAlertView*)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Need to determine the action based on the TAG
    if (buttonIndex != 0) {
        [self startNewMatch];
    }

    // Good place to show review prompt if they haven't already
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"showPrompt"]
            isEqualToString:@"Yes"]) {
        // Show the Prompt view
        self.promptView = [[ABXPromptView alloc]
            initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 200,
                                     CGRectGetWidth(self.view.bounds), 100)];
        self.promptView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        self.promptView.backgroundColor = [UIColor cyanColor];
        self.promptView.delegate = self;
        [self.view addSubview:self.promptView];
        // Turn prompt off for this version
        [[NSUserDefaults standardUserDefaults] setObject:@"No"
                                                  forKey:@"showPrompt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)sendSMS
{
    // Check if text messages should be sent
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([[defaults stringForKey:@"enableNotifications"] isEqualToString:@"On"]) {
        // Send the SMS message
        // If it can't be sent, iOS will pop up an alert so we don't have to do that
        MFMessageComposeViewController* textComposer = [[MFMessageComposeViewController alloc] init];
        [textComposer setMessageComposeDelegate:self];

        if ([MFMessageComposeViewController canSendText]) {
            NSString* notificationNumber =
                [defaults stringForKey:@"phoneNumberForNotification"];

            [textComposer
                setRecipients:[NSArray arrayWithObjects:notificationNumber, nil]];
            // Create new message
            NSString* smsMessage;
            if ([[self teamOrPlayer] isEqualToString:@"Player"]) {
                smsMessage = [self createPlayerMessageToSend];
            } else if ([[self teamOrPlayer] isEqualToString:@"Team"]) {
                smsMessage = [self createTeamMessageToSend];
            } else {
                smsMessage = [self createBlankMessageToSend];
            }
            
            [textComposer setBody:smsMessage];
            // Log to analytics that a message was sent
            if ([self canSendAnalytics]) {
                [self logMessagesSent:[self teamOrPlayer]];
            }
            
            
            // Show text message screen
            [self presentViewController:textComposer animated:YES completion:nil];
            
        }
    } // No messages to be sent, exit
}

- (NSString *)createPlayerMessageToSend
{
    // Clear the contents of the text message before creating a new one
    textMessage = nil;
    
    // Get the player name
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* playerName = [defaults stringForKey:@"playerNameForNotifications"];
    
    msgVisitor = [NSString stringWithString:self.visitingTeamName.text];
    msgHome = [NSString stringWithString:self.homeTeamName.text];
    
    // Format the text message
    textMessage = [NSString stringWithFormat: @"%@ has %d %@s and %d %@s!\nThe score is now %@ %d - %@ %d.", playerName, currSecondAction, self.rightActionLabel.text,
                   currFirstAction, self.leftActionLabel.text, msgVisitor, currVisitorScore, msgHome, currHomeScore];
    
    return textMessage;
}

- (NSString *)createTeamMessageToSend
{
    // Clear the contents of the text message before creating a new one
    textMessage = nil;
    
    msgVisitor = [NSString stringWithString:self.visitingTeamName.text];
    msgHome = [NSString stringWithString:self.homeTeamName.text];
    NSString *game = [NSString stringWithFormat:@"%@", self.gameNumber.text];
    if (currHomeScore > currVisitorScore) {
        textMessage = [NSString stringWithFormat: @"%@ is beating %@ %d - %d in game %@. The match is now %@ %ld - %@ %ld.",
                      msgHome, msgVisitor, currHomeScore, currVisitorScore, game, msgHome, (long)totalPastGamesHome, msgVisitor, (long)totalPastGamesVisitor];
    } else if (currVisitorScore > currHomeScore) {
        textMessage = [NSString stringWithFormat: @"%@ is beating %@ %d - %d in game %@. The match is now %@ %ld - %@ %ld.",
                      msgVisitor, msgHome, currVisitorScore, currHomeScore, game, msgVisitor, (long)totalPastGamesVisitor, msgHome, (long)totalPastGamesHome];
    } else {
        textMessage = [NSString stringWithFormat: @"In game %@ between %@ and %@, the score is %d - %d. The match is %@ %ld - %@ %ld.", game, msgHome, msgVisitor, currHomeScore, currVisitorScore, msgVisitor, (long)totalPastGamesVisitor, msgHome, (long)totalPastGamesHome];
    }
    
    return textMessage;
}

- (NSString *)createBlankMessageToSend
{
    // Clear the contents of the text message before creating a new one
    textMessage = @"";
    
    //return a blank message
    return textMessage;
}

- (NSString *)teamOrPlayer
{
    NSString *type;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    type = [defaults objectForKey:@"notificationsType"];
    if (!type) {
        return @"Blank";
    } else {
        return type;
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:
                         (UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    // Cast the viewController as a ScoreViewController so we can act on its
    // properties
    DefaultScoreViewController* oldViewController = (DefaultScoreViewController*)viewController;

    // Check the score, if it's more than 99, don't let the number get any higher
    if (oldViewController.score == 99) {
        return nil;
    }
    // Create a new scoreViewController
    DefaultScoreViewController* newViewController =
        [[DefaultScoreViewController alloc] init];

    // Determine what device we're on and set font size appropriately
    if (IS_IPAD()) {
        newViewController = [self createViewControllersForScore:0
                                                      withColor:ClearColor
                                                       fontSize:ipadScoreFont];
    } else {
        newViewController = [self createViewControllersForScore:0
                                                      withColor:ClearColor
                                                       fontSize:iphoneScoreFont];
    }

    newViewController.score = oldViewController.score + 1;

    // Check to see which view controller we're updating so the background color
    // can be set correctly
    if (pageViewController == _homePageViewController) {
        // Home team score changing
        newViewController.view.backgroundColor = self.homeColor;

    } else {
        // Visitor team score changing
        newViewController.view.backgroundColor = self.visitorColor;
    }

    return newViewController;
}

- (UIViewController*)pageViewController:
                         (UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    // Cast the viewController as a ScoreViewController so we can act on its
    // properties
    DefaultScoreViewController* oldViewController = (DefaultScoreViewController*)viewController;

    // Check the score, if it's 0, don't let the number get any lower
    if (oldViewController.score == 0) {
        return nil;
    }

    // Create a new scoreViewController
    DefaultScoreViewController* newViewController =
        [[DefaultScoreViewController alloc] init];

    // Determine what device we're on and set font size appropriately
    if (IS_IPAD()) {
        newViewController = [self createViewControllersForScore:0
                                                      withColor:ClearColor
                                                       fontSize:ipadScoreFont];
    } else {
        newViewController = [self createViewControllersForScore:0
                                                      withColor:ClearColor
                                                       fontSize:iphoneScoreFont];
    }
    // Setup the new view controller with the new, higher score
    //    DefaultScoreViewController *newViewController = [self
    //    createViewControllersForScore:0
    //                                                                              withColor:[UIColor clearColor]];
    //
    newViewController.score = oldViewController.score - 1;

    // Check to see which view controller we're updating so the background color
    // can be set correctly
    if (pageViewController == _homePageViewController) {
        // Home team score changing
        newViewController.view.backgroundColor = self.homeColor;

    } else {
        // Visitor team score changing
        newViewController.view.backgroundColor = self.visitorColor;
    }

    return newViewController;
}

- (void)pageViewController:(UIPageViewController*)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray*)previousViewControllers
        transitionCompleted:(BOOL)completed
{
    // If animation hasn't completed, exit; do not adjust score
    if (completed == NO) {
        return;
    }

    //	int previousScore =
    //((ScoreViewController*)previousViewControllers.firstObject).score;
    NSInteger currentScore = ((DefaultScoreViewController*)
                              pageViewController.viewControllers.firstObject).score;

    if (pageViewController == _homePageViewController) {
        _homePageViewController.view.backgroundColor = self.homeColor;
        currHomeScore = (int)currentScore;
    }

    if (pageViewController == _visitorPageViewController) {
        _visitorPageViewController.view.backgroundColor = self.visitorColor;
        currVisitorScore = (int)currentScore;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    // After entering team name, on either side, and tapping 'Done' or
    // anywhere else to dismiss keyboard, capture the names for the text msgs.
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.view endEditing:YES];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
