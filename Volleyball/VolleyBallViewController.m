//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by Frank Bara on 5/4/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.


#import "VolleyBallViewController.h"
#import "DefaultScoreViewController.h"
#import "ActionLabelTableViewController.h"
#import "NotificationsTableViewController.h"
#import "GBVersionTracking.h"
#import "Chameleon.h"

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
CGFloat const iphoneScoreFont = 118.0f;
NSString* colorScheme;
NSString *socialMessage;
int totalPastGamesHome;
int totalPastGamesVisitor;
static void * rightContext = &rightContext;
static void * leftContext = &leftContext;


@interface VolleyBallViewController ()  {
    // Instance variable to store all products returned from iTunes Connect
    NSArray* _products;
}

@property (weak, atomic) UIPageViewController* homePageViewController;
@property (weak, atomic) UIPageViewController* visitorPageViewController;
@property (weak, nonatomic) NSURL* baralabsURL;
@property (nonatomic, strong)id previewingContext;
//@property (weak, nonatomic) IBOutlet UIButton *rightActionNameButton;
//@property (weak, nonatomic) IBOutlet UIButton *leftActionNameButton;
@property (weak, nonatomic) IBOutlet UIButton *gameButton;
@property (weak, nonatomic) IBOutlet UILabel *visitingTeamPastName;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamPastName;
@property (weak, nonatomic) IBOutlet UIStackView *rightActionNameStackView;

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
    self.baralabsURL = [NSURL URLWithString:@"http://baralabs.com"];

    // TODO: Update tutorial?
    // Check if this is the first time the app has run.
    // If so, run tutorial.  If not, don't run turorial.
//    if ([GBVersionTracking isFirstLaunchEver] ||
//        [GBVersionTracking isFirstLaunchForVersion]) {
//        [self performSegueWithIdentifier:@"showTutorial" sender:self];
//    }

    [self resetGameAndNames];

    // Set Delegate's and DataSource's

    self.visitorPageViewController.dataSource = self;
    self.visitorPageViewController.delegate = self;
    self.homePageViewController.dataSource = self;
    self.homePageViewController.delegate = self;

    // Create bar button item and add them to the navigation bar
    UIBarButtonItem* settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMainActionNames)
                                                 name:@"updateActionNames"
                                               object:nil];
    // Register for notifications from SettingsTableViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:@"SettingsDone"
                                               object:nil];
    
    //Reset total game counts
    totalPastGamesHome = 0;
    totalPastGamesVisitor = 0;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];
    
    [self.homeTeamName addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMainActionNames)
                                                 name:@"updateActionNames"
                                               object:nil];
    // Register for notifications from SettingsTableViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:@"SettingsDone"
                                               object:nil];

    // Update the scoreview's colors in case they were changed in Settings
    // Initiaize all the UI elements depending on the device (font=188/118)
    if (IS_IPAD()) {
        [self initializeHomeScore:currHomeScore fontSize:ipadScoreFont];
        [self initializeVisitorScore:currVisitorScore fontSize:ipadScoreFont];
    } else {
        [self initializeVisitorScore:currVisitorScore fontSize:iphoneScoreFont];
        [self initializeHomeScore:currHomeScore fontSize:iphoneScoreFont];
    }

    [self loadActionNames];
    [self setupDynamicShortcuts];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Check for dark mode and adjust the colors accordingly
    if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        [self showDarkMode];
    } else {
        [self showLightMode];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.homeTeamName removeObserver:self forKeyPath:@"contentSize"];
}

- (IBAction)goToSettings:(UIBarButtonItem *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"settingsView" sender:self];
    });
    
}

- (void)initializePastGames
{
    // TODO: Update for iPad
    // There are 4 home & 4 visitor past scores that need to be reset to '0'
    for (UILabel* score in self.pastScoreCollection) {
        score.text = @"0";
        [score setFont:[UIFont systemFontOfSize:28 weight:UIFontWeightRegular]];
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
    DefaultScoreViewController* homeScoreViewController = [self createViewControllersForScore:score withColor:self.homeColor fontSize:scoreSize];
    if (IS_IPAD()) {
        [self.homeTeamPastName setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle]];
        [self.rightActionLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle]];
        self.rightActionNameNumber.font = self.rightActionLabel.font;
        for (UILabel *score in self.pastHomeScoreCollection) {
            score.font = self.homeTeamPastName.font;
        }
        self.gameNumber.font = self.rightActionLabel.font;
    }
    [self.homePageViewController setViewControllers:@[homeScoreViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)initializeVisitorScore:(int)score fontSize:(CGFloat)scoreSize
{
    self.visitorColor = [self colorVisitorScoreView];
    DefaultScoreViewController* visitorScoreViewController = [self createViewControllersForScore:score withColor:self.visitorColor fontSize:scoreSize];
    if (IS_IPAD()) {
        [self.visitingTeamPastName setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle]];
        [self.leftActionLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle]];
        self.leftActionNameNumber.font = self.leftActionLabel.font;
        for (UILabel* lable in self.pastVisitorScoreCollection) {
            lable.font = self.visitingTeamPastName.font;
        }
    }
    [self.visitorPageViewController setViewControllers:@[visitorScoreViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (DefaultScoreViewController*)createViewControllersForScore:(int)score withColor:(UIColor*)color fontSize:(CGFloat)scoreSize
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
    
    self.homeTeamName.backgroundColor = [colorHome darkenByPercentage:0.20];
    self.homeTeamName.textColor = ContrastColor(self.homeTeamName.backgroundColor, TRUE);
    self.homeTeamPastName.backgroundColor = colorHome;
    self.homeTeamPastName.textColor = self.homeTeamName.textColor;
    return colorHome;
}

// TODO: Update for changes to trait collection
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

    self.visitingTeamName.backgroundColor = [colorVisitor darkenByPercentage:0.20];
    self.visitingTeamName.textColor = ContrastColor(self.visitingTeamName.backgroundColor, TRUE);
    self.visitingTeamPastName.backgroundColor = colorVisitor;
    self.visitingTeamPastName.textColor = ContrastColor(colorVisitor, TRUE);

    return colorVisitor;
}

- (void)showDarkMode {
    UIImage *matchImage = [UIImage imageNamed:@"NewGameWhite.png"];
    [self.matchButton setImage:matchImage forState:UIControlStateNormal];
    
   UIImage *gameImage = [UIImage imageNamed:@"NewMatch3White.png"];
   [self.gameButton setImage:gameImage forState:UIControlStateNormal];
    [self changePastScoreColors:FlatRed loser:FlatYellow];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Dark" forKey:@"colorSetting"];
}

- (void)showLightMode {
    UIImage *matchImage = [UIImage imageNamed:@"NewGame.png"];
    [self.matchButton setImage:matchImage forState:UIControlStateNormal];
    
    UIImage *gameImage = [UIImage imageNamed:@"NewMatch3.png"];
    [self.gameButton setImage:gameImage forState:UIControlStateNormal];
    [self changePastScoreColors:FlatRed loser:FlatPlum];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Light" forKey:@"colorSetting"];
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
    self.homeTeamPastName.text = self.homeTeamName.text;
	  self.visitingTeamName.text = @"";
    self.visitingTeamPastName.text = self.visitingTeamName.text;
    totalPastGamesVisitor = 0;
    totalPastGamesHome = 0;
	
    [self initializePastGames];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    // called whenever the user has changed device appearance settings, like Dark Mode
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (previousTraitCollection.userInterfaceStyle != UITraitCollection.currentTraitCollection.userInterfaceStyle) {
        
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [self showDarkMode];
        } else {
            [self showLightMode];
            
        }
    }
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
            [menu setTargetRect:self.leftActionNameNumber.frame inView:self.leftActionNameNumber];
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
            [menu setTargetRect:self.rightActionNameNumber.frame inView:self.rightActionNameNumber];
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

- (void)gamePressedFromShortcut {
    [self gamePressed:self.gameButton];
}

- (void)matchPressedFromShortcut {
    [self newMatch:self.matchButton];
}

/*!
 *  What happens when 'Game' number is touched
 */
- (IBAction)gamePressed:(UIButton*)sender
{
    // TODO: Update for iPad
    // Grab the game number
    int lableNum = [self.gameNumber.text intValue];
    UIFont *iPhoneFont = [UIFont systemFontOfSize:26];
    // Update the past scores, set the winner in red text
    // For a tie, both get plain black
    switch (lableNum) {
    case 1:
        self.homeGame1.text = [NSString stringWithFormat:@"%d", currHomeScore];
        self.visitGame1.text = [NSString stringWithFormat:@"%d", currVisitorScore];
        if (currHomeScore > currVisitorScore) {
            self.homeGame1.textColor = FlatRed;
            totalPastGamesHome = totalPastGamesHome + 1;
            if (IS_IPAD()) {
                [self.homeGame1 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.homeGame1 setFont:iPhoneFont];
            }

        } else if (currHomeScore < currVisitorScore) {
            self.visitGame1.textColor = FlatRed;
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame1 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.visitGame1 setFont:iPhoneFont];
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
                [self.homeGame2 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.homeGame2 setFont:iPhoneFont];
            }
        } else if (currHomeScore < currVisitorScore) {
            self.visitGame2.textColor = FlatRed;
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame2 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.visitGame2 setFont:iPhoneFont];
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
                [self.homeGame3 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.homeGame3 setFont:iPhoneFont];
            }
        } else if (currHomeScore < currVisitorScore) {
            self.visitGame3.textColor = FlatRed;
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame3 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.visitGame3 setFont:iPhoneFont];
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
                [self.homeGame4 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.homeGame4 setFont:iPhoneFont];
            }
        } else if (currHomeScore < currVisitorScore) {
            self.visitGame4.textColor = FlatRed;
            totalPastGamesVisitor = totalPastGamesVisitor + 1;
            if (IS_IPAD()) {
                [self.visitGame4 setFont:[UIFont systemFontOfSize:30]];
            } else {
                [self.visitGame4 setFont:iPhoneFont];
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
        [self initializePastGames];
//        for (UILabel* score in self.pastScoreCollection) {
//            score.text = @"0";
//            if (IS_IPAD()) {
//                [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:30]];
//            } else {
//                [score setFont:[UIFont fontWithName:@"Helvetica Neue" size:20]];
//            }
//        }
        [self startNewMatch];
    }
    currHomeScore = 0;
    currVisitorScore = 0;
}

/*
 *  What happens when right Action number is touched
 */
- (IBAction)rightActionPressed:(UIButton*)sender
{
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
    

    // Get current number and add 1
    int lableNum = [self.leftActionNameNumber.text intValue];
    if (lableNum == 99) {
        lableNum = 0;
    } else {
        lableNum = lableNum + 1;
    }

    // Keep track of the number for this action in case the user comes back to it
    // during this match
    //[defaults setInteger:lableNum forKey:self.leftActionLabel.text];

    self.leftActionNameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    currFirstAction = lableNum;
    
    // Send the text message
    [self sendSMS];
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
    
    
    
    // Determine if review prompt should be shown
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"showPrompt"]) {
        [SKStoreReviewController requestReview];
        [defaults setBool:FALSE forKey:@"showPrompt"];
    }

    [self resetGameAndNames];
    //[self initializePastGames];
}

- (IBAction)newMatch:(UIButton *)sender {
    // TODO: Verify if TAG_MATCH is still needed.
//#define TAG_MATCH 1
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Match?", nil) message:NSLocalizedString(@"Reset team names, scores, action names, and start a new match? This can't be undone.", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *no = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self startNewMatch];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:no];
    [alert addAction:yes];
    
   // Get the active VC
    UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([activeVC isKindOfClass:[UINavigationController class]]) {
        activeVC = [(UINavigationController *)activeVC visibleViewController];
    }
    [activeVC presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - Social Accounts

- (void)enableSocialButtons
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Off" forKey:@"enableTwitter"];
    [defaults setObject:@"Off" forKey:@"enableFacebook"];

}

//#pragma mark - 3D Touch
//
//- (BOOL)checkFor3DTouch {
//    BOOL is3DTouchAvail = NO;
//    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
//        is3DTouchAvail = YES;
//    }
//    return is3DTouchAvail;
//}

- (void)setupDynamicShortcuts {
    UIApplicationShortcutItem *newMatch = [[UIApplicationShortcutItem alloc] initWithType:@"$(PRODUCT_BUNDLE_IDENTIFIER).NewMatch"
                                                                           localizedTitle:NSLocalizedString(@"New Match", @"Start a new match")
                                                                        localizedSubtitle:NSLocalizedString(@"Start a new match", @"Start a new match button.")
                                                                                     icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"Sport Net-50"]
                                                                                 userInfo:nil];
    
    UIApplicationShortcutItem *newGame = [[UIApplicationShortcutItem alloc] initWithType:@"$(PRODUCT_BUNDLE_IDENTIFIER).NewGame"
                                                                           localizedTitle:NSLocalizedString(@"New Set", @"Start a new set")
                                                                        localizedSubtitle:NSLocalizedString(@"Start a new set", @"Start a new game button.")
                                                                                    icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"volleyball-50"]
                                                                                 userInfo:nil];
    
    [UIApplication sharedApplication].shortcutItems = @[newMatch, newGame];
    
}

// TODO: Previewing Context Doesn't work inside StackView
//- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
//    //TODO: Showing menu in wrong location
//    //Check if we're not already displaying the view controller
//    if ([self.presentedViewController isKindOfClass:[ActionLabelTableViewController class]] ||
//        [self.presentedViewController isKindOfClass:[NotificationsTableViewController class]]) {
//        return nil;
//    }
//    // TODO: Fix Context Menu
//    int actionSide = 0;
//    if (CGRectContainsPoint([self.rightActionLabel.layer frame], location)) {
//        actionSide = 2;
//        [self logShortcutUsed:(NSString *)self.rightActionLabel.titleLabel];
//        previewingContext.sourceRect = self.rightActionNameButton.frame;
//    } else if (CGRectContainsPoint([self.leftActionNameButton frame], location)) {
//        actionSide = 1;
//        [self logShortcutUsed:(NSString *)self.leftActionNameButton.titleLabel];
//        previewingContext.sourceRect = self.leftActionNameButton.frame;
//    } else if (CGRectContainsPoint([self.sendMessageImage frame], location)){
//        actionSide = -1;
//        [self logShortcutUsed:(NSString *)self.sendMessageImage.titleLabel];
//        previewingContext.sourceRect = self.sendMessageImage.frame;
//    }
//
//    if (actionSide > 0) {
//        ActionLabelTableViewController *aVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ActionNames"];
//        aVC.selectedActionRow = actionSide;
//        return aVC;
//    } else if (actionSide < 0) {
//        NotificationsTableViewController *notiVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
//        return notiVC;
//    }
//
//    return nil;
//}

//- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
//    self.definesPresentationContext = TRUE;
//    [self.navigationController showViewController:viewControllerToCommit sender:self];
//}

//- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
//    [super traitCollectionDidChange:previousTraitCollection];
//    if ([self checkFor3DTouch]) {
//        if (!self.previewingContext) {
//            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
//        }
//    } else {
//        if (self.previewingContext) {
//            [self unregisterForPreviewingWithContext:self.previewingContext];
//            self.previewingContext = nil;
//        }
//    }
//}

- (void)getMainActionNames
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentLeft, *currentRight;
    currentLeft = self.leftActionLabel.text;
    currentRight = self.rightActionLabel.text;
    
    switch ([defaults integerForKey:@"updatedActionNumber"]) {
        case 1:
            if ([currentLeft isEqualToString:[defaults stringForKey:@"leftActionName"]]) {
                break;
            } else {
                self.leftActionLabel.text = [defaults stringForKey:@"leftActionName"];
                self.leftActionNameNumber.text = NSLocalizedString(@"0", @"Number 0.");
                break;
            }
        case 2:
            if ([currentRight isEqualToString:[defaults stringForKey:@"rightActionName"]]) {
                break;
            } else {
                self.rightActionLabel.text = [defaults stringForKey:@"rightActionName"];
                self.rightActionNameNumber.text = NSLocalizedString(@"0", @"Number 0.");
                break;
            }
        default:
            break;
    }
}

#pragma mark - Text Messages & Alerts

- (void)messageComposeViewController: (MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendSMS
{
    // Check if text messages should be sent
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([[defaults stringForKey:@"enableNotifications"] isEqualToString:@"On"]) {
        // Send the SMS message
        // If it can't be sent, iOS will pop up an alert so I don't have to do that
        MFMessageComposeViewController* textComposer = [[MFMessageComposeViewController alloc] init];
        [textComposer setMessageComposeDelegate:self];

        if ([MFMessageComposeViewController canSendText]) {
            NSString* notificationNumber = [defaults stringForKey:@"phoneNumberForNotification"];

            [textComposer setRecipients:[NSArray arrayWithObjects:notificationNumber, nil]];
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
    textMessage = [NSString stringWithFormat: @"%@ has %d %@ and %d %@!\nThe score is now %@ %d - %@ %d.", playerName, currSecondAction, self.rightActionLabel.text, currFirstAction, self.leftActionLabel.text, msgVisitor, currVisitorScore, msgHome, currHomeScore];
    
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

- (UIViewController*)pageViewController: (UIPageViewController*)pageViewController viewControllerAfterViewController:(UIViewController*)viewController
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

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController viewControllerBeforeViewController:(UIViewController*)viewController
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

#pragma mark - UITextView Delegates

//- (void)textViewDidEndEditing:(UITextView *)textView {
//    self.homeTeamName.text = textView.text;
//}



#pragma mark - UITextFieldDelegate

// Update the past team names whenever the main text field is updated
- (IBAction)visitorNameEntered:(UITextField *)sender {
    self.visitingTeamPastName.text = sender.text;
}

- (IBAction)homeNameEntered:(UITextField *)sender {
    self.homeTeamPastName.text = sender.text;
}




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

#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
