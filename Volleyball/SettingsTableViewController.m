//
//  SettingsTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ActionLabelTableViewController.h"
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import "VolleyBallViewController.h"
#import <AppbotX/ABXFAQsViewController.h>
#import <ChameleonFramework/Chameleon.h>
#import <GoogleAnalytics/GAITracker.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"	
#pragma clang diagnostic ignored "-Wprotocol"

@interface SettingsTableViewController () <UIViewControllerPreviewingDelegate> {
    BOOL isPurchased;
	NSString *teamChange;
}

@property int actionRow;
@property NSString* existingRightActionName;
@property NSString* existingLeftActionName;
@property ActionLabelTableViewController* actionNameVC;
@property UIPopoverController* aPopover;
@property (weak, nonatomic) IBOutlet UILabel* twitterCellLabel;
@property (weak, nonatomic) IBOutlet UILabel* facebookCellLabel;
@property (nonatomic, strong)id previewingContext;

@end

@implementation SettingsTableViewController {
    NSString* firstStartTime;
}

- (id)init
{
    self = [super init];

    if (self) {
    }
    return self;
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;

    UIBarButtonItem* saveButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(saveAndClose)];
    UIImage* image = [UIImage imageNamed:@"Info44.png"];
    UIBarButtonItem* infoButton =
        [[UIBarButtonItem alloc] initWithImage:image
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(showSupportView)];
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                             target:self
                             action:nil];

    fixedSpace.width = 20.0f;

    if (IS_IPAD()) {
        self.navigationItem.rightBarButtonItem = infoButton;
        self.navigationItem.leftBarButtonItem = saveButton;
    } else {
        self.navigationItem.rightBarButtonItem = infoButton;
    }

    // Set the switch if messages will be sent
    if ([[self getSendNotifications] isEqualToString:@"On"]) {
        [self.sendNotificationSwitch setSelectedSegmentIndex:0];
        if ([[self getNotificationType] isEqualToString:@"Team"]) {
            [self.notificationTypeSwitch setSelectedSegmentIndex:0];
            self.notificationName.enabled = FALSE;
        } else if ([[self getNotificationType] isEqualToString:@"Player"]) {
            [self.notificationTypeSwitch setSelectedSegmentIndex:1];
            self.notificationName.enabled = TRUE;
        } else {
            [self.notificationTypeSwitch setSelectedSegmentIndex:2];
            self.notificationName.enabled = TRUE;
        }
    } else {
        [self.sendNotificationSwitch setSelectedSegmentIndex:1];
    }
    //Check for 3D Touch
    if ([self checkFor3DTouch]) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getActionNames)
                                                     name:@"updateActionNames"
                                                   object:nil];
    }
}

- (void)saveAndClose
{
    [self.parentViewController dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Setup Google Analytics tracker for this screen
    if ([self getAnalytics]) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Settings"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Is this the first time running this VC?
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    firstStartTime = [defaults stringForKey:@"firstStartTime"];

    if ([firstStartTime length] < 1) {
        // First time starting this VC. Set notifications type to Player
        
        //Set initial score background colors
        self.homeTeamColor.backgroundColor = FlatBlue;
        self.visitingTeamColor.backgroundColor = FlatOrange;
        [defaults setObject:@"No" forKey:@"firstStartTime"];
    } else {
        // Get the saved score background colors
        self.homeTeamColor.backgroundColor =
            [self getSavedScoreColors:@"homeTeamColor"];
        self.visitingTeamColor.backgroundColor =
            [self getSavedScoreColors:@"visitorTeamColor"];
    }

    // Get the Action names
    [self getActionNames];

    // Get the player name and notification number
    [self getPlayerNameAndNumber];

    // Set selected segment for messages
    if ([[self getSendNotifications] isEqualToString:@"On"]) {
        [self.sendNotificationSwitch setSelectedSegmentIndex:0];
    } else {
        [self.sendNotificationSwitch setSelectedSegmentIndex:1];
    }
    
    // Set selected segment for notification types
    if ([firstStartTime length] < 1) {
        [self.notificationTypeSwitch setSelectedSegmentIndex:1];
    } else {
        if ([[self getNotificationType] isEqualToString:@"Team"]) {
            [self.notificationTypeSwitch setSelectedSegmentIndex:0];
            self.nameOfPlayer.enabled = FALSE;
        } else if ([[self getNotificationType] isEqualToString:@"Player"]) {
            [self.notificationTypeSwitch setSelectedSegmentIndex:1];
            self.nameOfPlayer.enabled = TRUE;
        } else {
            [self.notificationTypeSwitch setSelectedSegmentIndex:2];
            self.nameOfPlayer.enabled = TRUE;
        }
    }

    // Set selected segment for analytics
    if ([[self getAnalytics] isEqualToString:@"Opt out"]) {
        [self.analyticsSwitch setSelectedSegmentIndex:0];
    } else {
        [self.analyticsSwitch setSelectedSegmentIndex:1];
    }

    // Set the selected segment for color settings
    if ([[self getColorSettings] isEqualToString:@"Complementary"]) {
        [self.colorSettings setSelectedSegmentIndex:0];
    } else if ([[self getColorSettings] isEqualToString:@"Dark"]) {
        [self.colorSettings setSelectedSegmentIndex:1];
    } else {
        [self.colorSettings setSelectedSegmentIndex:2];
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"purchasedSocial"]) {
        self.twitterSwitch.enabled = TRUE;
        self.twitterCellLabel.text = @"Send with Twitter?";
        self.facebookCellLabel.text = @"Send with Facebook?";
        // Set the Twitter switch if messages will be sent
        if ([[self getTwitterNotifications] isEqualToString:@"On"]) {
            [self.twitterSwitch setSelectedSegmentIndex:0];
        } else {
            [self.twitterSwitch setSelectedSegmentIndex:1];
        }

        // Set the Facebook switch if messages will be sent
        self.facebookSwitch.enabled = TRUE;
        if ([[self getFacebookNotifications] isEqualToString:@"On"]) {
            [self.facebookSwitch setSelectedSegmentIndex:0];
        } else {
            [self.facebookSwitch setSelectedSegmentIndex:1];
        }
    } else {
        // User has not made purchase so disable social switches
        self.twitterCellLabel.text = @"Twitter available with purchase";
        self.facebookCellLabel.text = @"Facebook available with purchase";
        self.twitterSwitch.enabled = FALSE;
        self.facebookSwitch.enabled = FALSE;
    }
    
    [self checkFor3DTouch];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Save our settings before the scene goes away
    [self saveScoreColors];
    [self savePlayerName:self.nameOfPlayer.text
         saveNotifyPhone:self.notificationName.text];
    [self saveActionNames:self.leftActionNameSelected.text
               secondName:self.rightActionNameSelected.text];
    [self notificationSwitch:self.sendNotificationSwitch];
    [self notificationTypeSwitch:self.notificationTypeSwitch];
    [self sendAnalytics:self.analyticsSwitch];
    [self colorSettings:self.colorSettings];
    [self sendWithFacebook:self.facebookSwitch];
    [self sendWithTwitter:self.twitterSwitch];

    // Remove our observer for IAP
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:IAPHelperProductPurchaseNotification
                object:nil];

    // Set the notification when Settings is done
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsDone"
                                                        object:self];

    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Save/Load Player Name
/*!
 *  Saves the name of the player and the phone number for SMS message.
 *
 *  @param playerName   Name of the player
 *  @param notifyNumber Phone number, in (555)555-5555 format, that will be sent
 *                      SMS messages
 */
- (void)savePlayerName:(NSString*)playerName
       saveNotifyPhone:(NSString*)notifyNumber
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([playerName length] > 1) {
        [defaults setObject:playerName forKey:@"playerNameForNotifications"];
    } else {
        [defaults setObject:@" " forKey:@"playerNameForNotifications"];
    }

    if ([notifyNumber length] > 1) {
        [defaults setObject:notifyNumber forKey:@"phoneNumberForNotification"];
    } else {
        [defaults setObject:@" " forKey:@"phoneNumberForNotification"];
    }

    [self saveUserDefaults];
}

- (void)getPlayerNameAndNumber
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    self.nameOfPlayer.text =
        [defaults stringForKey:@"playerNameForNotifications"];
    self.notificationName.text =
        [defaults stringForKey:@"phoneNumberForNotification"];
}

#pragma mark - Save/Load Action Name
/*!
 *  Saves the top and bottom Action Names that are displayed and included in SMS
 *messages.
 *
 *  @param leftActionName  The top Action name
 *  @param rightActionName The bottom Action name
 */
- (void)saveActionNames:(NSString*)leftActionName
             secondName:(NSString*)rightActionName
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ([leftActionName length] > 1) {
        [defaults setObject:leftActionName forKey:@"leftActionName"];
    } else {
        [defaults setObject:@"Not Selected" forKey:@"leftActionName"];
    }

    if ([rightActionName length] > 1) {
        [defaults setObject:rightActionName forKey:@"rightActionName"];
    } else {
        [defaults setObject:@"Not Selected" forKey:@"rightActionName"];
    }

    [self saveUserDefaults];
}

/*!
 *  Returns the Action names from user defaults
 *  and populates the labels on the main screen
 */
- (void)getActionNames
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    NSString* tempName;
    tempName = [defaults stringForKey:@"leftActionName"];

    if ([tempName length] < 1) {
        self.leftActionNameSelected.text = @"Not Selected";
    } else {
        self.leftActionNameSelected.text = tempName;
    }

    tempName = [defaults stringForKey:@"rightActionName"];

    if ([tempName length] < 1) {
        self.rightActionNameSelected.text = @"Not Selected";
    } else {
        self.rightActionNameSelected.text = tempName;
    }
}

#pragma mark - Save/Load Score Background Colors
/*!
 *  Gets the background score color and returns it
 *
 *  @param team Either the home or visitor team.  If home, use "homeTeamColor".
 *  if visitor, use "visitorTeamColor".
 *
 *  @return UIColor that is the background score color
 */
- (UIColor*)getSavedScoreColors:(NSString*)team
{
    UIColor* teamColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];

    NSData* teamData = [[NSUserDefaults standardUserDefaults] dataForKey:team];

    if (teamData != nil) {
        teamColor = (UIColor*)[NSKeyedUnarchiver unarchiveObjectWithData:teamData];
    } else {
        teamColor = [UIColor blueColor];
    }

    return teamColor;
}

- (void)saveScoreColors
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    // Set the home team color
    UIColor* colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    colorHome = self.homeTeamColor.backgroundColor;
    NSData* colorHomeData =
        [NSKeyedArchiver archivedDataWithRootObject:colorHome];
    [defaults setObject:colorHomeData forKey:@"homeTeamColor"];

    // Set the visiting team color
    UIColor* colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    colorVisitor = self.visitingTeamColor.backgroundColor;
    NSData* colorVisitorData =
        [NSKeyedArchiver archivedDataWithRootObject:colorVisitor];
    [defaults setObject:colorVisitorData forKey:@"visitorTeamColor"];

    [self saveUserDefaults];
}

#pragma mark - Score Background Color Methods

/*!
 * @discussion The background color of the home team's score
 * @param sender This param is not used.
 */
- (IBAction)homeTeamBackgroundColor:(id)sender
{
	/* OLD CODE
	// Change the button background color each time the button is tapped
    //self.homeTeamColor.backgroundColor = RandomFlatColor;
	*/
	
	//Store the team I'm changing
	teamChange = @"Home";
	//Use color picker to get color
	FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPickerWithColor:self.homeTeamColor.backgroundColor
																						delegate:self];

	[colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
	[self presentViewController:colorPicker animated:TRUE completion:nil];
}

/*!
 * @discussion The background color of the visiting team's score
 * @param sender This param is not used.
 */
- (IBAction)visitingTeamBackgroundColor:(id)sender
{
	/* OLD CODE
	// Change the button background color each time the button is tapped
    //self.visitingTeamColor.backgroundColor = RandomFlatColor;
	*/
	
	//Store the team I'm changing
	teamChange = @"Visitor";
	//Use color picker to get color
	FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPickerWithColor:self.visitingTeamColor.backgroundColor
																						delegate:self];
	
	[colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
	[self presentViewController:colorPicker animated:TRUE completion:nil];
	
}

#pragma mark - FCColorPicker Delegate

- (void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color
{
	if ([teamChange isEqualToString:@"Home"]) {
		self.homeTeamColor.backgroundColor = color;
	} else {
		self.visitingTeamColor.backgroundColor = color;
	}
	//Save the colors so they will be loaded when the Settings VC is shown again
	[self saveScoreColors];
	teamChange = nil;
	[self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker
{
	teamChange = nil;
	[self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - FAQ

- (IBAction)getFAQ:(UIButton*)sender
{
    [ABXFAQsViewController showFromController:self
                            hideContactButton:NO
                              contactMetaData:nil
                                initialSearch:nil];
}

#pragma mark - Analytics Opt Out
- (IBAction)sendAnalytics:(UISegmentedControl*)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];

    // Save the value of the opt out
    switch (selectedSegmentIndex) {
    case 0:
		// Do not track
		[[GAI sharedInstance] setOptOut:YES];
		[defaults setObject:@"Opt out" forKey:@"analyticsChoice"];
        break;
    case 1:
		// Ok to track
		[[GAI sharedInstance] setOptOut:NO];
		[defaults setObject:@"Opt in" forKey:@"analyticsChoice"];	
        break;
    default:
        break;
    }
    [self saveUserDefaults];
}

- (NSString*)getAnalytics
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    return [defaults stringForKey:@"analyticsChoice"];
}

#pragma mark - Notificaion Switchs

- (IBAction)notificationTypeSwitch:(UISegmentedControl *)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    
    //Save the segmented value
    switch (selectedSegmentIndex) {
        case 0:
            // Send messages about the teams playing
            [defaults setObject:@"Team" forKey:@"notificationsType"];
            self.nameOfPlayer.enabled = FALSE;
            break;
        case 1:
            // Send messages about the individual player only
            [defaults setObject:@"Player" forKey:@"notificationsType"];
            self.nameOfPlayer.enabled = TRUE;
            break;
        case 2:
            //Create blank msg for custom use
            [defaults setObject:@"Blank" forKey:@"notificationsType"];
            self.nameOfPlayer.enabled = TRUE;
            break;
        default:
            break;
    }
    [self saveUserDefaults];

}

- (NSString *)getNotificationType
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults stringForKey:@"notificationsType"];
}

- (IBAction)notificationSwitch:(id)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];

    // Save the segmented value
    switch (selectedSegmentIndex) {
    case 0:
        // Send SMS messages
        [defaults setObject:@"On" forKey:@"enableNotifications"];
        break;
    case 1:
        // Don't send SMS messagees
        [defaults setObject:@"Off" forKey:@"enableNotifications"];
            break;
    default:
        break;
    }
    [self saveUserDefaults];
}

- (NSString*)getSendNotifications
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    return [defaults stringForKey:@"enableNotifications"];
}


#pragma mark - Color Switch

- (IBAction)colorSettings:(UISegmentedControl*)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];

    // Save the selected color segment
    switch (selectedSegmentIndex) {
    case 0:
        // Complementary colors
        [defaults setObject:@"Complementary" forKey:@"colorSettings"];
        break;
    case 1:
        // Dark colors
        [defaults setObject:@"Dark" forKey:@"colorSettings"];
        break;
    case 2:
        // No special color scheme
        [defaults setObject:@"Off" forKey:@"colorSettings"];
        break;
    default:
        break;
    }
    [self saveUserDefaults];
}



- (NSString*)getColorSettings
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    return [defaults stringForKey:@"colorSettings"];
}

#pragma mark - Social Sharing

- (IBAction)sendWithTwitter:(UISegmentedControl*)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    VolleyBallViewController* volleyVC = [[VolleyBallViewController alloc] init];

    // Save the segmented value
    switch (selectedSegmentIndex) {
    case 0:
        // Send Twitter messages
        {
            [defaults setObject:@"On" forKey:@"enableTwitter"];
            volleyVC.mainPageTwitterButton.enabled = TRUE;
        }
        break;
    case 1:
        // Don't send Twitter messages
        {
            [defaults setObject:@"Off" forKey:@"enableTwitter"];
            volleyVC.mainPageTwitterButton.enabled = FALSE;
        }
    default:
        break;
    }
    [self saveUserDefaults];
}

- (IBAction)sendWithFacebook:(UISegmentedControl*)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    VolleyBallViewController* volleyVC = [[VolleyBallViewController alloc] init];

    // Save the segmented value
    switch (selectedSegmentIndex) {
    case 0: { // Send Facebook messages
        [defaults setObject:@"On" forKey:@"enableFacebook"];
        volleyVC.mainPageFacebookButton.enabled = TRUE;
    } break;
    case 1: { // Don't send Facebook messages
        [defaults setObject:@"Off" forKey:@"enableFacebook"];
        volleyVC.mainPageFacebookButton.enabled = FALSE;
    }
    default:
        break;
    }
    [self saveUserDefaults];
}

- (NSString*)getTwitterNotifications
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    return [defaults stringForKey:@"enableTwitter"];
}

- (NSString*)getFacebookNotifications
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    return [defaults stringForKey:@"enableFacebook"];
}

#pragma mark - People Picker Methods

- (IBAction)getPhoneNumberFromAddressBook:(id)sender
{
    ABPeoplePickerNavigationController* picker =
        [[ABPeoplePickerNavigationController alloc] init];

    picker.peoplePickerDelegate = self;

    // Only show a person's phone number and email
    NSArray* displayedItems = [NSArray
        arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
                         [NSNumber numberWithInt:kABPersonEmailProperty], nil];
    picker.displayedProperties = displayedItems;

    // Show the picker
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:
            (ABPeoplePickerNavigationController*)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//3-16-16: Don't support iOS 7 anymore, commenting for now
/*!
 *  New ABPeoplePickerNavigationController for iOS 8 only.
 *  All this will do here is call the iOS7 version.  Keep both around
 *  for compantibility.
 *
 *  @param person The phone number of the person selected from Contacts
 */
//- (void)peoplePickerNavigationController:
//            (ABPeoplePickerNavigationController*)peoplePicker
//                         didSelectPerson:(ABRecordRef)person
//                                property:(ABPropertyID)property
//                              identifier:(ABMultiValueIdentifier)identifier
//{
//    [self peoplePickerNavigationController:peoplePicker
//        shouldContinueAfterSelectingPerson:person
//                                  property:property
//                                identifier:identifier];
//}

- (void)displayPerson:(ABRecordRef)person
         targetNumber:(NSString*)selectedNumber
{
    NSString* phone = nil;

    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);

    if (ABMultiValueGetCount(phoneNumbers) >= 1) {
        // If they pick a contact, save that number
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:selectedNumber forKey:@"phoneNumberForNotification"];
    } else {
        // Contact didn't have a phone number on their contact.  Send alert to tell
        // user.
        UIAlertView* alert = [[UIAlertView alloc]
                initWithTitle:@"Phone Number Error"
                      message:@"The contact either doesn't have a valid phone "
                      @"number or the app can't access the phone "
                      @"number.\nPlease select a different contact."
                     delegate:nil
            cancelButtonTitle:@"Ok"
            otherButtonTitles:nil];
        [alert show];
    }

    CFRelease(phoneNumbers);
}

// Called from iOS 8
- (BOOL)peoplePickerNavigationController:
            (ABPeoplePickerNavigationController*)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonPhoneProperty) {
        ABMultiValueRef numbers = ABRecordCopyValue(person, property);
        NSString* targetNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(
            numbers, ABMultiValueGetIndexForIdentifier(numbers, identifier));

        // Send the 'person' info to displayPerson to add the phone number to the
        // text field
        [self displayPerson:person targetNumber:targetNumber];
    }

    [self dismissViewControllerAnimated:YES completion:nil];

    return NO;
}

// Does not allow users to perform default actions such as dialing a phone
// number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController*)personViewController
    shouldPerformDefaultActionForPerson:(ABRecordRef)person
                               property:(ABPropertyID)property
                             identifier:
                                 (ABMultiValueIdentifier)identifierForValue
{
    // Gets the phone number the user selected
    if (property == kABPersonPhoneProperty) {
        ABMultiValueRef numbers = ABRecordCopyValue(person, property);
        NSString* targetNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(
            numbers,
            ABMultiValueGetIndexForIdentifier(numbers, identifierForValue));
    }
    [self dismissViewControllerAnimated:YES completion:nil];

    return NO;
}

- (void)showSupportView
{
    // Show the Support view
    [self performSegueWithIdentifier:@"supportView" sender:self];
}

- (void)saveUserDefaults
{
    // Save settings
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults synchronize]) {
        // Synchronize could't happen; show user alert and exit
        UIAlertView* alert = [[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"Settings could not be saved", nil)
                      message:nil
                     delegate:nil
            cancelButtonTitle:NSLocalizedString(@"Ok", nil)
            otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - ActionName Delegate

- (void)actionNameSelected:(NSString*)actionName
{
    [self setActionName:actionName];
	//Close this view
    if (IS_IPAD()) {
        [self.actionNameVC dismissViewControllerAnimated:FALSE completion:nil];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"actionNameView"]) {
        self.actionNameVC = [[ActionLabelTableViewController alloc] init];
        self.actionNameVC = segue.destinationViewController;
        self.actionNameVC.delegate = self;
        self.actionNameVC.selectedActionRow = self.actionRow;
    }
}

- (IBAction)unwindFromModalViewController:(UIStoryboardSegue*)segue
{
    if ([segue.sourceViewController
            isKindOfClass:[ActionLabelTableViewController class]]) {
        // Unwinding from Action Name VC
        self.actionNameVC = segue.sourceViewController;
        [self setActionName:self.actionNameVC.selectedActionName];
    }
}

- (void)setActionName:(NSString*)name
{
    // Remove the row number from actionRow
    self.actionRow = 0;

    [self saveUserDefaults];

    // Refresh the popover values
    [self viewWillAppear:TRUE];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Change the selected row color so the entire row doesn't become gray when
    // it's touched
    [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleNone];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    int actionTag = (int)cell.tag;

    if (actionTag == 1 || actionTag == 2) {
        self.existingLeftActionName = self.leftActionNameSelected.text;
        self.existingRightActionName = self.rightActionNameSelected.text;
        if (actionTag == 1) {
            // The left Action Name row was selected
            self.actionRow = 1;
        } else {
            // The right Action Name row was selected
            self.actionRow = 2;
        }

    } else {
        // In-App Purchase was selected
        return;
    }

    // Action Name row was selected so segue to that VC
    [self performSegueWithIdentifier:@"actionNameView" sender:self];
}

#pragma mark - Peek/Pop

- (BOOL)checkFor3DTouch {
    BOOL is3DTouchAvail = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
        is3DTouchAvail = YES;
    }
    return is3DTouchAvail;
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    //Check if we're not already displaying the view controller
    if ([self.presentedViewController isKindOfClass:[ActionLabelTableViewController class]]) {
        return nil;
    }
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:path];
    self.actionRow = (int)tableCell.tag;
    //Only do 3D touch for Action Names rows
    if (!self.actionRow) {
        return nil;
    }

    if (path) {
        previewingContext.sourceRect = tableCell.frame;
        //Get the storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //Setup the view controller by initializing it from the storyboard
        ActionLabelTableViewController *previewController = [storyboard instantiateViewControllerWithIdentifier:@"ActionNames"];
        if (self.actionRow == 1 || self.actionRow == 2) {
            previewController.selectedActionRow = self.actionRow;
            //Log the user used 3D Touch
            if ([self getAnalytics]) {
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker set:kGAIScreenName value:@"Settings"];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            }
        }
        
        return previewController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self checkFor3DTouch]) {
        if (!self.previewingContext) {
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    } else {
        if (self.previewingContext) {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}

#pragma mark - UITextField Phone Formatting

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
    [self.view endEditing:TRUE];
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    [self.view endEditing:YES];
    [textField resignFirstResponder];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField*)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString*)string
{
    // calculate new length
    NSInteger moddedLength = textField.text.length - (range.length - string.length);

    // max size.
    if (moddedLength >= 13) {
        return NO;
    }

    // Reject non-number characters
    if (range.length == 0 && ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }

    // Auto-add hyphen before appending 4rd or 7th digit
    if ([self range:range ContainsLocation:3] ||
        [self range:range ContainsLocation:7]) {
        textField.text =
            [self formatPhoneString:[textField.text
                                        stringByReplacingCharactersInRange:range
                                                                withString:string]];
        return NO;
    }

    return YES;
}

#pragma mark Phone Formatting Helpers

- (NSString*)formatPhoneString:(NSString*)preFormatted
{
    // delegate only allows numbers to be entered, so '-' is the only non-legal
    // char.
    NSString* workingString =
        [preFormatted stringByReplacingOccurrencesOfString:@"-" withString:@""];

    // insert first '-'
    if (workingString.length > 3) {
        workingString =
            [workingString stringByReplacingCharactersInRange:NSMakeRange(3, 0)
                                                   withString:@"-"];
    }

    // insert second '-'
    if (workingString.length > 7) {
        workingString =
            [workingString stringByReplacingCharactersInRange:NSMakeRange(7, 0)
                                                   withString:@"-"];
    }

    return workingString;
}

- (bool)range:(NSRange)range ContainsLocation:(NSInteger)location
{
    if (range.location <= location && range.location + range.length >= location) {
        return true;
    }

    return false;
}

#pragma clang diagnostic pop
@end
