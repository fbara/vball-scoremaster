//
//  SettingsTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ActionLabelTableViewController.h"
#import "SupportTableViewController.h"
#import "VolleyBallViewController.h"
//#import <ChameleonFramework/Chameleon.h>
#import "Chameleon.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"	
#pragma clang diagnostic ignored "-Wprotocol"

@interface SettingsTableViewController () <UIViewControllerPreviewingDelegate, UIAdaptivePresentationControllerDelegate> {
    BOOL isPurchased;
	NSString *teamChange;
}

@property int actionRow;
@property NSString* existingRightActionName;
@property NSString* existingLeftActionName;
@property ActionLabelTableViewController* actionNameVC;
@property UIPopoverController* aPopover;
@property (nonatomic, strong)UIPreviewActionGroup *previewActions;

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

}

- (void)saveAndClose
{
    [self.parentViewController dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setStatusBarStyle:UIStatusBarStyleContrast];

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
    [self getSettingsActionNames];

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

    // Set the selected segment for color settings
    // TODO: For Color Settings
//    if ([[self getColorSettings] isEqualToString:@"Complementary"]) {
//        [self.colorSettings setSelectedSegmentIndex:0];
//    } else if ([[self getColorSettings] isEqualToString:@"System"]) {
//        [self.colorSettings setSelectedSegmentIndex:1];
//    } else {
//        [self.colorSettings setSelectedSegmentIndex:2];
//    }
    
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
//    [self colorSettings:self.colorSettings];
    
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
- (void)getSettingsActionNames
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
	//Store the team I'm changing
	teamChange = @"Visitor";
	//Use color picker to get color
	FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPickerWithColor:self.visitingTeamColor.backgroundColor
																						delegate:self];
	
    //[colorPicker setModalPresentationStyle:UIModalPresentationFullScreen];
    //[colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
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

#pragma mark - Extras

- (void)leaveReview:(UIButton *)sender {
    // Allow the user to leave App Store review
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/id886670213?action=write-review"] options:@{} completionHandler:nil];

}

#pragma mark - Notification Switches

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

// TODO: Update here for Dark Mode
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
        // System colors
        [defaults setObject:@"System" forKey:@"colorSettings"];
        break;
//    case 2:
//        // Follow the system default (Dark Mode support)
//        [defaults setObject:@"Off" forKey:@"colorSettings"];
//        break;
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
    //TODO: Change for 3.8
    
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
//    VolleyBallViewController* volleyVC = [[VolleyBallViewController alloc] init];
//
//    // Save the segmented value
//    switch (selectedSegmentIndex) {
//    case 0:
//        // Send Twitter messages
//        {
//            [defaults setObject:@"On" forKey:@"enableTwitter"];
//            volleyVC.mainPageTwitterButton.enabled = TRUE;
//        }
//        break;
//    case 1:
//        // Don't send Twitter messages
//        {
//            [defaults setObject:@"Off" forKey:@"enableTwitter"];
//            volleyVC.mainPageTwitterButton.enabled = FALSE;
//        }
//    default:
//        break;
//    }
//    [self saveUserDefaults];
}

//- (IBAction)sendWithFacebook:(UISegmentedControl*)sender
//{
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
//    VolleyBallViewController* volleyVC = [[VolleyBallViewController alloc] init];
//
//    // Save the segmented value
//    switch (selectedSegmentIndex) {
//    case 0: { // Send Facebook messages
//        [defaults setObject:@"On" forKey:@"enableFacebook"];
//        volleyVC.mainPageFacebookButton.enabled = TRUE;
//    } break;
//    case 1: { // Don't send Facebook messages
//        [defaults setObject:@"Off" forKey:@"enableFacebook"];
//        volleyVC.mainPageFacebookButton.enabled = FALSE;
//    }
//    default:
//        break;
//    }
//    [self saveUserDefaults];
//}

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

- (void)getPhoneNumber {
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.delegate = self;
    contactPicker.editing = false;
    
    // Only show a contact who has at least 1 phone number
    NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"(phoneNumbers.@count > 0)"];
    NSPredicate *contactSelectionPredicate = [NSPredicate predicateWithFormat:@"phoneNumbers.@count == 1"];
    NSArray *propertyKeys = @[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey];
    
    contactPicker.displayedPropertyKeys = propertyKeys;
    contactPicker.predicateForEnablingContact = enablePredicate;
    contactPicker.predicateForSelectionOfContact = contactSelectionPredicate;
    
    //Show picker
    contactPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:contactPicker animated:true completion:nil];

}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    //Called when contact has only 1 phone number listed in contact card.
    CNLabeledValue *phoneNumberValue = contact.phoneNumbers.firstObject;
    CNPhoneNumber *phoneNumber = phoneNumberValue.value;
    NSString *phoneNumberString = phoneNumber.stringValue;
    [self setPhoneNumberForMessages:phoneNumberString];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    //Called when contact has multiple phone numbers listed in contact card.
    CNContact *contact = contactProperty.contact;
    CNPhoneNumber *contactPhone = contactProperty.value;
    NSString *phoneNumber = contactPhone.stringValue;
    
    [self setPhoneNumberForMessages:phoneNumber];
}

- (void)setPhoneNumberForMessages:(NSString *)phoneNumber {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:phoneNumber forKey:@"phoneNumberForNotification"];
}

// CNContactPicker - End

- (IBAction)getPhoneNumberFromAddressBook:(id)sender
{
    [self getPhoneNumber];
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
    //if (IS_IPAD()) {
        [self.actionNameVC dismissViewControllerAnimated:FALSE completion:nil];
    //}
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

//- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
//    self.modalPresentationStyle = UIModalPresentationFullScreen;
//}

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
        // Action Name row was selected so segue to that VC
        [self performSegueWithIdentifier:@"actionNameView" sender:self];

    } else if (actionTag == 3) {
        // Show Support VC
        [self performSegueWithIdentifier:@"supportView" sender:self];
        return;
    } else {
        // In-App Purchase was selected
        return;
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
