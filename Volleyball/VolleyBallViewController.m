//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by Frank Bara on 5/4/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

/**
 @file VolleyBallViewController.m
 @brief Main view controller for the Volleyball scoring app.
 
 This controller manages the primary user interface for tracking volleyball match scores,
 including setting and updating team names, scores, actions, and handling user interactions
 such as gestures, button presses, and notifications. It also supports color schemes, 3D Touch shortcuts,
 and sending score updates via SMS.
 */

#import "VolleyBallViewController.h"
#import "DefaultScoreViewController.h"
#import "ActionLabelTableViewController.h"
#import "NotificationsTableViewController.h"
#import "GBVersionTracking.h"
#import "Chameleon.h"

@import Accounts;
@import StoreKit;
@import UIKit;

/// Embed segue identifier for home score container
NSString* const EMBED_HOME = @"embedHome";

/// Embed segue identifier for visitor score container
NSString* const EMBED_VISITOR = @"embedVisitor";

/// Current home team score value
int currHomeScore = 0;

/// Current visitor team score value
int currVisitorScore = 0;

/// Current second action count for right action
int currSecondAction = 0;

/// Current first action count for left action
int currFirstAction = 0;

/// Message label for home team
NSString* msgHome = @"HOME";

/// Message label for visitor team
NSString* msgVisitor = @"VISITOR";

/// Text message content to be sent via SMS
NSString* textMessage;

/// Screenshot image placeholder (not currently used)
UIImage* screenImage;

/// iTunes app store identifier for the app
static NSString* const kiTunesID = @"886670213";

/// Font size for score numbers on iPad devices
CGFloat const ipadScoreFont = 220.0f;

/// Font size for score numbers on iPhone devices
CGFloat const iphoneScoreFont = 118.0f;

/// Current selected color scheme name
NSString* colorScheme;

/// Social media message content placeholder
NSString *socialMessage;

/// Total number of past games won by home team
int totalPastGamesHome;

/// Total number of past games won by visitor team
int totalPastGamesVisitor;

/// Context pointer for right action name KVO (not used here)
static void * rightContext = &rightContext;

/// Context pointer for left action name KVO (not used here)
static void * leftContext = &leftContext;

@interface VolleyBallViewController ()  {
    /// Array holding all available in-app purchase products from iTunes Connect
    NSArray* _products;
}

/// PageViewController managing the home team score views
@property (weak, atomic) UIPageViewController* homePageViewController;

/// PageViewController managing the visitor team score views
@property (weak, atomic) UIPageViewController* visitorPageViewController;

/// URL for BaraLabs website used in social sharing links
@property (weak, nonatomic) NSURL* baralabsURL;

/// Previewing context for 3D Touch peek and pop (if enabled)
@property (nonatomic, strong)id previewingContext;

/// Button to trigger new game or set (IBOutlet connected in storyboard)
@property (weak, nonatomic) IBOutlet UIButton *gameButton;

/// UILabel showing the past name of the visiting team
@property (weak, nonatomic) IBOutlet UILabel *visitingTeamPastName;

/// UILabel showing the past name of the home team
@property (weak, nonatomic) IBOutlet UILabel *homeTeamPastName;

/// UIStackView containing the right action name labels and buttons
@property (weak, nonatomic) IBOutlet UIStackView *rightActionNameStackView;

@end

@implementation VolleyBallViewController

#pragma mark - Initialize Screen

/**
 @brief Called before the main view controller is loaded, assigns embedded page view controllers.
 
 @param segue The UIStoryboardSegue triggering the embedding.
 @param sender The object initiating the segue.
 
 Sets up references to the embedded home and visitor PageViewControllers used for displaying scores.
 */
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:EMBED_HOME]) {
        self.homePageViewController = segue.destinationViewController;
    }

    if ([segue.identifier isEqualToString:EMBED_VISITOR]) {
        self.visitorPageViewController = segue.destinationViewController;
    }
}

/**
 @brief Called after the view has been loaded, initializes UI elements and gesture recognizers.
 
 Sets initial URLs, resets game scores and team names, configures delegates and data sources,
 installs swipe gesture recognizers for score containers, and registers notifications.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set home URL for Twitter and Facebook messages
    self.baralabsURL = [NSURL URLWithString:@"http://baralabs.com"];

    // TODO: Update tutorial?
    // Check if this is the first time the app has run.
    // If so, run tutorial.  If not, don't run tutorial.
//    if ([GBVersionTracking isFirstLaunchEver] ||
//        [GBVersionTracking isFirstLaunchForVersion]) {
//        [self performSegueWithIdentifier:@"showTutorial" sender:self];
//    }

    // Reset all game scores, names, and past games
    [self resetGameAndNames];

    // Set delegates and data sources for both score PageViewControllers
    self.visitorPageViewController.dataSource = self;
    self.visitorPageViewController.delegate = self;
    self.homePageViewController.dataSource = self;
    self.homePageViewController.delegate = self;

    // Create bar button item and add it to the navigation bar for Settings
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

    // Create the same swipe gesture for the visitor team container
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
    for (UIGestureRecognizer *gesture in _homePageViewController.view.gestureRecognizers) {
        [gesture requireGestureRecognizerToFail:homeSwipeGesture];
    }

    for (UIGestureRecognizer *gesture in _visitorPageViewController.view.gestureRecognizers) {
        [gesture requireGestureRecognizerToFail:visitorSwipeGesture];
    }

    // Load the action names from user defaults and display them
    [self loadActionNames];
    
    // Register to update displayed action names when notified
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMainActionNames)
                                                 name:@"updateActionNames"
                                               object:nil];
    // Register for notifications from SettingsTableViewController to update view
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:@"SettingsDone"
                                               object:nil];
    
    // Reset total game counts for past matches
    totalPastGamesHome = 0;
    totalPastGamesVisitor = 0;
}

/**
 @brief Called just before the view appears on screen, updates UI to current settings.
 
 @param animated Indicates if the appearance is animated.
 
 Refreshes scoreview fonts and colors depending on device type and color scheme,
 reloads action names, and sets up dynamic quick shortcuts.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];
    
    // Observe content size changes for home team name label to adjust layout if needed
    [self.homeTeamName addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    // Register to update displayed action names when notified (added again for safety)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMainActionNames)
                                                 name:@"updateActionNames"
                                               object:nil];
    // Register for notifications from SettingsTableViewController to update view
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:@"SettingsDone"
                                               object:nil];

    // Update the scoreview's colors and fonts depending on device type
    if (IS_IPAD()) {
        [self initializeHomeScore:currHomeScore fontSize:ipadScoreFont];
        [self initializeVisitorScore:currVisitorScore fontSize:ipadScoreFont];
    } else {
        [self initializeVisitorScore:currVisitorScore fontSize:iphoneScoreFont];
        [self initializeHomeScore:currHomeScore fontSize:iphoneScoreFont];
    }

    // Reload action names from user defaults
    [self loadActionNames];
    
    // Setup home screen quick action shortcuts
    [self setupDynamicShortcuts];
}

/**
 @brief Called after the view lays out its subviews, adjusts colors for appearance mode.
 
 Checks the current user interface style and updates colors accordingly for dark or light mode.
 */
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Check for dark mode and adjust the colors accordingly
    if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        [self showDarkMode];
    } else {
        [self showLightMode];
    }
}

/**
 @brief Called before the view disappears, removes observers.
 
 @param animated Indicates if the disappearance is animated.
 
 Removes the contentSize observer on the home team name label to prevent leaks.
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.homeTeamName removeObserver:self forKeyPath:@"contentSize"];
}

/**
 @brief Triggered when the Settings button in the navigation bar is tapped.
 
 @param sender The UIBarButtonItem that triggered the action.
 
 Performs a segue to the settings view controller on the main thread.
 */
- (IBAction)goToSettings:(UIBarButtonItem *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"settingsView" sender:self];
    });
    
}

/**
 @brief Initializes past game score labels and resets colors.
 
 Sets all past score labels to zero and applies color formatting based on current color scheme.
 Resets total past games counters.
 */
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

/**
 @brief Initializes the home team score PageViewController with given score and font size.
 
 @param score The initial score to display.
 @param scoreSize The font size for the score label.
 
 Configures the home team's score view controller, including fonts and colors for iPad devices.
 */
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

/**
 @brief Initializes the visitor team score PageViewController with given score and font size.
 
 @param score The initial score to display.
 @param scoreSize The font size for the score label.
 
 Configures the visitor team's score view controller, including fonts and colors for iPad devices.
 */
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

/**
 @brief Creates and returns a DefaultScoreViewController with given score, background color, and font size.
 
 @param score The score to display on the view controller.
 @param color The background color for the score view.
 @param scoreSize The font size for the score number.
 
 @return A newly created DefaultScoreViewController initialized with the specified parameters.
 */
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

/**
 @brief Retrieves and applies the color scheme for the home team's score view.
 
 @return UIColor representing the home team's background color.
 
 Reads the saved color from user defaults or defaults to blue color,
 updates the home team name and past name label backgrounds and text colors accordingly.
 */
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

/**
 @brief Retrieves and applies the color scheme for the visitor team's score view.
 
 @return UIColor representing the visitor team's background color.
 
 Reads the saved color from user defaults or defaults to orange color,
 updates the visitor team name and past name label backgrounds and text colors accordingly.
 */
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

/**
 @brief Updates UI colors and images to match dark mode appearance.
 
 Changes relevant button images and updates past score colors for dark mode,
 and saves current color setting to user defaults.
 */
- (void)showDarkMode {
    UIImage *matchImage = [UIImage imageNamed:@"NewGameWhite.png"];
    [self.matchButton setImage:matchImage forState:UIControlStateNormal];
    
    UIImage *gameImage = [UIImage imageNamed:@"NewMatch3White.png"];
    [self.gameButton setImage:gameImage forState:UIControlStateNormal];
    [self changePastScoreColors:FlatRed loser:FlatYellow];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Dark" forKey:@"colorSetting"];
}

/**
 @brief Updates UI colors and images to match light mode appearance.
 
 Changes relevant button images and updates past score colors for light mode,
 and saves current color setting to user defaults.
 */
- (void)showLightMode {
    UIImage *matchImage = [UIImage imageNamed:@"NewGame.png"];
    [self.matchButton setImage:matchImage forState:UIControlStateNormal];
    
    UIImage *gameImage = [UIImage imageNamed:@"NewMatch3.png"];
    [self.gameButton setImage:gameImage forState:UIControlStateNormal];
    [self changePastScoreColors:FlatRed loser:FlatPlum];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Light" forKey:@"colorSetting"];
}

/**
 @brief Changes the colors of the past score labels to indicate winner and loser.
 
 @param winTeam UIColor for the team that won the set.
 @param loseTeam UIColor for the team that lost the set.
 
 Compares each past game score pair and highlights the winning team's score in red
 and the losing team's score in the specified losing color.
 */
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

/**
 @brief Resets game state including scores, team names, and action counters.
 
 Clears current scores and action numbers, sets team names to empty,
 and resets total past games counters to zero. Also initializes past game labels.
 */
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

/**
 @brief Called when trait collection changes, updates UI for dark/light mode changes.
 
 @param previousTraitCollection The previous trait collection before the change.
 
 Handles changes in user interface style, such as dark mode toggling,
 and adjusts the UI accordingly.
 */
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
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

/**
 @brief Loads the action names from user defaults and updates the UI labels accordingly.
 
 If an action name is not set, displays "Not Selected" as placeholder text.
 */
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

/**
 @brief Allows all gesture recognizers to recognize gestures simultaneously.
 
 @param gestureRecognizer The gesture recognizer requesting to recognize simultaneously.
 @param otherGestureRecognizer The other gesture recognizer involved.
 @return YES to allow multiple gesture recognizers at once.
 
 This enables swipe gestures and page view controller pan/tap gestures to coexist and function correctly.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UISwipeGestureRecognizers

/**
 @discussion Handles swipe gestures on the home and visitor score containers to swap their positions.
 
 @param recognizer The UISwipeGestureRecognizer that triggered this action.
 
 Animates the swapping of the home and visitor team score containers, team name labels,
 and past score labels to visually switch the side of the teams.
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

/**
 @brief IBAction triggered when the send message button is pressed.
 
 @param sender The UIButton sending the action.
 
 Sends a text message with the current scores and actions without changing any values.
 */
- (IBAction)sendInstantMessage:(UIButton*)sender
{
    // Send a text message without changing the Action numbers
    [self sendSMS];
}

/**
 @brief Handles long press gesture on the left action number label to show reset menu.
 
 @param recognizer UILongPressGestureRecognizer that detected the long press.
 
 If the left action number is non-zero, presents a UIMenuController with options to reset to zero or cancel.
 */
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

/**
 @brief Handles long press gesture on the right action number label to show reset menu.
 
 @param recognizer UILongPressGestureRecognizer that detected the long press.
 
 If the right action number is non-zero, presents a UIMenuController with options to reset to zero or cancel.
 */
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

/**
 @brief Resets the left action number label to zero.
 
 Invoked from UIMenuController action.
 */
- (void)resetLeftToZero
{
    self.leftActionNameNumber.text = @"0";
}

/**
 @brief Resets the right action number label to zero.
 
 Invoked from UIMenuController action.
 */
- (void)resetRightToZero
{
    self.rightActionNameNumber.text = @"0";
}

/**
 @brief Dummy method to enable display of UIMenuController items.
 
 This method intentionally does nothing and is required for the cancel menu item.
 */
- (void)leaveNumberAsIs
{
    // Dummy method to allow UIMenuItems to be visible
}

/**
 @brief Indicates this view controller can become first responder.
 
 @return YES always to allow UIMenuController to work.
 */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Button Presses

/**
 @brief Called from dynamic shortcut to simulate pressing the Game button.
 */
- (void)gamePressedFromShortcut {
    [self gamePressed:self.gameButton];
}

/**
 @brief Called from dynamic shortcut to simulate pressing the Match button.
 */
- (void)matchPressedFromShortcut {
    [self newMatch:self.matchButton];
}

/**
 @brief IBAction triggered when the Game button is pressed.
 
 @param sender The UIButton triggering the action.
 
 Advances the current set/game, updates past score labels and colors, resets scores for new set,
 and starts a new match if the set number exceeds limit.
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

/**
 @brief IBAction triggered when the right action number is pressed.
 
 @param sender The UIButton triggering the action.
 
 Increments the number displayed for the right action, loops back to zero after 99,
 updates the current second action count, and sends a text message update.
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

/**
 @brief IBAction triggered when the left action number is pressed.
 
 @param sender The UIButton triggering the action.
 
 Increments the number displayed for the left action, loops back to zero after 99,
 updates the current first action count, and sends a text message update.
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

/**
 @brief Starts a new match by resetting scores, games, and requesting review prompt if needed.
 
 Initializes UI elements based on device type, resets game state,
 and requests app store review if the user is eligible.
 */
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

/**
 @brief IBAction triggered when the user taps the New Match button.
 
 @param sender The UIButton triggering the action.
 
 Presents an alert confirming if the user wants to reset the match.
 If confirmed, starts a new match and dismisses the alert.
 */
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
    
    // Get the active view controller to present the alert
    UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([activeVC isKindOfClass:[UINavigationController class]]) {
        activeVC = [(UINavigationController *)activeVC visibleViewController];
    }
    [activeVC presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Social Accounts

/**
 @brief Enables social media buttons by disabling both Twitter and Facebook options.
 
 Currently sets Twitter and Facebook enable flags to "Off" in user defaults.
 */
- (void)enableSocialButtons
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
     //TODO: Change for 3.8 - ADD
    [defaults setObject:@"Off" forKey:@"enableTwitter"];
    [defaults setObject:@"Off" forKey:@"enableFacebook"];
}

#pragma mark - 3D Touch

/**
 @brief Checks if 3D Touch capability is available on the device.
 
 @return YES if device supports 3D Touch, NO otherwise.
 */
- (BOOL)checkFor3DTouch {
    BOOL is3DTouchAvail = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
        is3DTouchAvail = YES;
    }
    return is3DTouchAvail;
}

/**
 @brief Sets up quick action shortcuts for the app icon.
 
 Adds shortcuts for starting a new match and starting a new set/game.
 */
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

/**
 @brief Provides view controller for 3D Touch previewing (peek).
 
 @param previewingContext The previewing context requesting the preview controller.
 @param location The location of the touch in the source view.
 @return The view controller to preview at the given location or nil if none.
 
 Currently disabled and returns nil.
 */
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    //TODO: Showing menu in wrong location
    //Check if we're not already displaying the view controller
    if ([self.presentedViewController isKindOfClass:[ActionLabelTableViewController class]] ||
        [self.presentedViewController isKindOfClass:[NotificationsTableViewController class]]) {
        return nil;
    }
    // TODO: Fix Context Menu
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

//    if (actionSide > 0) {
//        ActionLabelTableViewController *aVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ActionNames"];
//        aVC.selectedActionRow = actionSide;
//        return aVC;
//    } else if (actionSide < 0) {
//        NotificationsTableViewController *notiVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
//        return notiVC;
//    }

    return nil;
}

/**
 @brief Commits view controller to display after 3D Touch peek and pop.
 
 @param previewingContext The previewing context.
 @param viewControllerToCommit The view controller to show.
 
 Pushes the view controller onto the navigation stack.
 */
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    self.definesPresentationContext = TRUE;
    [self.navigationController showViewController:viewControllerToCommit sender:self];
}

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

/**
 @brief Updates main action names from user defaults when notified.
 
 Reads the updates from user defaults and refreshes the UI labels and numbers accordingly.
 */
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

/**
 @brief Delegate method called when the message compose view controller finishes sending or cancelling.
 
 @param controller The MFMessageComposeViewController instance.
 @param result The result of the message compose (sent, cancelled, failed).
 
 Dismisses the message compose view controller after completion.
 */
- (void)messageComposeViewController: (MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 @brief Sends an SMS message with the current match and action details if notifications are enabled.
 
 Checks user defaults for notification settings and phone number,
 creates and presents the MFMessageComposeViewController with the appropriate message body.
 */
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
            // Create new message body depending on notification type
            NSString* smsMessage;
            if ([[self teamOrPlayer] isEqualToString:@"Player"]) {
                smsMessage = [self createPlayerMessageToSend];
            } else if ([[self teamOrPlayer] isEqualToString:@"Team"]) {
                smsMessage = [self createTeamMessageToSend];
            } else {
                smsMessage = [self createBlankMessageToSend];
            }
            
            [textComposer setBody:smsMessage];
        
            // Present the text message view controller
            [self presentViewController:textComposer animated:YES completion:nil];
            
        }
    } // No messages to be sent, exit
}

/**
 @brief Creates a formatted text message string for player notifications.
 
 @return NSString containing the player message.
 
 Includes player name, current scores, and action counts in the message.
 */
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

/**
 @brief Creates a formatted text message string for team notifications.
 
 @return NSString containing the team message.
 
 Includes current set scores and total match wins.
 */
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

/**
 @brief Returns a blank message string.
 
 @return Empty NSString.
 */
- (NSString *)createBlankMessageToSend
{
    // Clear the contents of the text message before creating a new one
    textMessage = @"";
    
    //return a blank message
    return textMessage;
}

/**
 @brief Returns the type of notifications enabled (Player, Team, or Blank).
 
 @return NSString representing notification type.
 */
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

/**
 @brief Returns the view controller after the provided view controller in the PageViewController.
 
 @param pageViewController The page view controller requesting this information.
 @param viewController The currently visible view controller.
 @return The next view controller with incremented score or nil if maximum reached.
 */
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

/**
 @brief Returns the view controller before the provided view controller in the PageViewController.
 
 @param pageViewController The page view controller requesting this information.
 @param viewController The currently visible view controller.
 @return The previous view controller with decremented score or nil if minimum reached.
 */
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

/**
 @brief Called when the PageViewController finishes animating a page transition.
 
 @param pageViewController The page view controller sending the message.
 @param finished Whether the animation finished.
 @param previousViewControllers The view controllers visible before transition.
 @param completed Whether the page transition was completed.
 
 Updates the current score and background color for either home or visitor score controllers after animation.
 */
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

/**
 @brief Updates the visitor team's past name label when visitor name field is edited.
 
 @param sender The UITextField that provided the new visitor name.
 */
- (IBAction)visitorNameEntered:(UITextField *)sender {
    self.visitingTeamPastName.text = sender.text;
}

/**
 @brief Updates the home team's past name label when home name field is edited.
 
 @param sender The UITextField that provided the new home name.
 */
- (IBAction)homeNameEntered:(UITextField *)sender {
    self.homeTeamPastName.text = sender.text;
}

/**
 @brief Called when any text field finishes editing.
 
 @param textField The UITextField that ended editing.
 
 Trims whitespace and resigns first responder to dismiss keyboard.
 */
- (void)textFieldDidEndEditing:(UITextField*)textField
{
    // After entering team name, on either side, and tapping 'Done' or
    // anywhere else to dismiss keyboard, capture the names for the text msgs.
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.view endEditing:YES];
    [textField resignFirstResponder];
}

/**
 @brief Called when the return key is pressed on the keyboard while editing a text field.
 
 @param textField The UITextField currently being edited.
 @return YES to allow the text field to resign first responder.
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

/**
 @brief Called when touches begin on the view, dismisses keyboard if active.
 
 @param touches The set of UITouch instances.
 @param event The UIEvent associated with the touches.
 */
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Memory Mgmt

/**
 @brief Called when the app receives a memory warning.
 
 Releases any resources that can be recreated.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

