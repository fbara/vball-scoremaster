//
//  SettingsTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ActionLabelTableViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"
#import "VolleyBallViewController.h"

@interface SettingsTableViewController ()

@property int actionRow;
@property NSString *existingRightActionName;
@property NSString *existingLeftActionName;
@property ActionLabelTableViewController *actionNameVC;
@property UIPopoverController *aPopover;

@end

@implementation SettingsTableViewController
{
    NSString *firstStartTime;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@"Save"
                                           style:UIBarButtonItemStyleDone
                                           target:self
                                            action:@selector(saveAndClose)];

    UIImage *image = [UIImage imageNamed:@"Info44.png"];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]
                                   initWithImage:image
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(showSupportView)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:self
                                   action:nil];
    fixedSpace.width = 20.0f;
    NSArray *barButtonItems = @[saveButton,fixedSpace,infoButton];
    self.navigationItem.rightBarButtonItems = barButtonItems;
    
    //Set the switch if messages will be sent
    if ([[self getSendNotifications] isEqualToString:@"On"]) {
        [self.sendNotificationSwitch setSelectedSegmentIndex:0];
    } else {
        [self.sendNotificationSwitch setSelectedSegmentIndex:1];
    }
    
//??? Hide Social code for this version
/*
    //Set the Twitter switch if messages will be sent
    if ([[self getTwitterNotifications] isEqualToString:@"On"]) {
        [self.twitterSwitch setSelectedSegmentIndex:0];
    } else {
        [self.twitterSwitch setSelectedSegmentIndex:1];
    }
    
    //Set the Facebook switch if messages will be sent
    if ([[self getFacebookNotifications] isEqualToString:@"On"]) {
        [self.facebookSwitch setSelectedSegmentIndex:0];
    } else {
        [self.facebookSwitch setSelectedSegmentIndex:1];
    }
*/
    
}
                                   
- (void)saveAndClose
{
    [self.parentViewController dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Setup Google Analytics tracker for this screen
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    //Is this the first time running this VC?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    firstStartTime = [defaults stringForKey:@"firstStartTime"];
    
    if ([firstStartTime length] < 1) {
        //First time starting this VC. Set initial score background colors
        self.homeTeamColor.backgroundColor = FlatBlue;
        self.visitingTeamColor.backgroundColor = FlatOrange;
        [defaults setObject:@"No" forKey:@"firstStartTime"];
    } else {
        //Get the saved score background colors
        self.homeTeamColor.backgroundColor = [self getSavedScoreColors:@"homeTeamColor"];
        self.visitingTeamColor.backgroundColor = [self getSavedScoreColors:@"visitorTeamColor"];
    }
    
    //Get the Action names
    [self getActionNames];
    
    //Get the player name and notification number
    [self getPlayerNameAndNumber];
    
    //Set selected segment for messages
    if ([[self getSendNotifications] isEqualToString:@"On"]) {
        [self.sendNotificationSwitch setSelectedSegmentIndex:0];
    } else {
        [self.sendNotificationSwitch setSelectedSegmentIndex:1];
    }
    
    //Set selected segment for messages
    if ([[self getAnalytics] isEqualToString:@"Opt out"]) {
        [self.analyticsSwitch setSelectedSegmentIndex:0];
    } else {
        [self.analyticsSwitch setSelectedSegmentIndex:1];
    }
    
    //Set the selected segment for color settings
    if ([[self getColorSettings] isEqualToString:@"Complementary"]) {
        [self.colorSettings setSelectedSegmentIndex:0];
    } else if ([[self getColorSettings] isEqualToString:@"Dark"]) {
        [self.colorSettings setSelectedSegmentIndex:1];
    } else {
        [self.colorSettings setSelectedSegmentIndex:2];
    }

//???  Removing Social code for this version
/*
    //Set the Twitter switch if messages will be sent
    if ([[self getTwitterNotifications] isEqualToString:@"On"]) {
        [self.twitterSwitch setSelectedSegmentIndex:0];
    } else {
        [self.twitterSwitch setSelectedSegmentIndex:1];
    }
    
    //Set the Facebook switch if messages will be sent
    if ([[self getFacebookNotifications] isEqualToString:@"On"]) {
        [self.facebookSwitch setSelectedSegmentIndex:0];
    } else {
        [self.facebookSwitch setSelectedSegmentIndex:1];
    }
*/
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    //Save our settings before the scene goes away
    [self saveScoreColors];
    [self savePlayerName:self.nameOfPlayer.text saveNotifyPhone:self.notificationName.text];
    [self saveActionNames:self.leftActionNameSelected.text secondName:self.rightActionNameSelected.text];
    [self notificationSwitch:self.sendNotificationSwitch];
    [self sendAnalytics:self.analyticsSwitch];
    [self colorSettings:self.colorSettings];
//??? Remove Social code for this version, to be added as IAP
//    [self sendWithFacebook:self.facebookSwitch];
//    [self sendWithTwitter:self.twitterSwitch];
    
    //Set the notification when Settings is done
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingsDone"
                                                        object:self];
    
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder { return YES; }

#pragma mark - Save/Load Player Name
/*!
 *  Saves the name of the player and the phone number for SMS message.
 *
 *  @param playerName   Name of the player
 *  @param notifyNumber Phone number, in (555)555-5555 format, that will be sent 
 *                      SMS messages
 */
- (void)savePlayerName:(NSString *)playerName saveNotifyPhone:(NSString *)notifyNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.nameOfPlayer.text = [defaults stringForKey:@"playerNameForNotifications"];
    self.notificationName.text = [defaults stringForKey:@"phoneNumberForNotification"];
}

#pragma mark - Save/Load Action Name
/*!
 *  Saves the top and bottom Action Names that are displayed and included in SMS messages.
 *
 *  @param leftActionName  The top Action name
 *  @param rightActionName The bottom Action name
 */
- (void)saveActionNames:(NSString *)leftActionName secondName:(NSString *)rightActionName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([leftActionName length] > 1) {
        
        [defaults setObject:leftActionName forKey:@"leftActionName"];
    } else {
        [defaults setObject:@"SPIKE" forKey:@"leftActionName"];
    }
    
    if ([rightActionName length] > 1) {
        
        [defaults setObject:rightActionName forKey:@"rightActionName"];
    } else {
        [defaults setObject:@"ACE" forKey:@"rightActionName"];
    }
    
    [self saveUserDefaults];
}

/*!
 *  Returns the Action names from user defaults
 *  and populates the labels on the main screen
 */
- (void)getActionNames
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempName;
    tempName = [defaults stringForKey:@"leftActionName"];
    
    if ([tempName length] < 1) {
        self.leftActionNameSelected.text = @"SPIKE";
    } else {
        self.leftActionNameSelected.text = tempName;
    }
    
    tempName = [defaults stringForKey:@"rightActionName"];
    
    if ([tempName length] < 1) {
        self.rightActionNameSelected.text = @"ACE";
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
- (UIColor *)getSavedScoreColors:(NSString *)team
{
    UIColor *teamColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    NSData *teamData = [[NSUserDefaults standardUserDefaults] dataForKey:team];
    
    if (teamData != nil) {
        teamColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:teamData];
    } else {
        teamColor = [UIColor blueColor];
    }
    
    return teamColor;
}

- (void)saveScoreColors
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Set the home team color
    UIColor *colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    colorHome = self.homeTeamColor.backgroundColor;
    NSData *colorHomeData = [NSKeyedArchiver archivedDataWithRootObject:colorHome];
    [defaults setObject:colorHomeData forKey:@"homeTeamColor"];
    
    //Set the visiting team color
    UIColor *colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    colorVisitor = self.visitingTeamColor.backgroundColor;
    NSData *colorVisitorData = [NSKeyedArchiver archivedDataWithRootObject:colorVisitor];
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
    //Change the button background color each time the button is tapped
    self.homeTeamColor.backgroundColor = RandomFlatColor;
}

/*!
 * @discussion The background color of the visiting team's score
 * @param sender This param is not used.
 */
- (IBAction)visitingTeamBackgroundColor:(id)sender
{
    //Change the button background color each time the button is tapped
    self.visitingTeamColor.backgroundColor = RandomFlatColor;
}

#pragma mark - FAQ

- (IBAction)getFAQ:(UIButton *)sender
{
    [ABXFAQsViewController showFromController:self
                            hideContactButton:NO
                              contactMetaData:nil
                                initialSearch:nil];
}


#pragma mark - Analytics Opt Out
- (IBAction)sendAnalytics:(UISegmentedControl *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    
    //Save the value of the opt out
    switch (selectedSegmentIndex) {
        case 0:
            //Do not track
            [[GAI sharedInstance] setOptOut:YES];
            [defaults setObject:@"Opt out" forKey:@"analyticsChoice"];
            break;
        case 1:
            //Ok to track
            [[GAI sharedInstance] setOptOut:NO];
            [defaults setObject:@"Opt in" forKey:@"analyticsChoice"];
            break;
        default:
            break;
    }
    [self saveUserDefaults];
}

- (NSString *)getAnalytics
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults stringForKey:@"analyticsChoice"];
}

#pragma mark - Text Notificaion Switch
- (IBAction)notificationSwitch:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    
    //Save the segmented value
    switch (selectedSegmentIndex) {
        case 0:
            //Send SMS messages
            [defaults setObject:@"On" forKey:@"enableNotifications"];
            break;
        case 1:
            //Don't send SMS messagees
            [defaults setObject:@"Off" forKey:@"enableNotifications"];
        default:
            break;
    }
    [self saveUserDefaults];
}

- (NSString *)getSendNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults stringForKey:@"enableNotifications"];
}

#pragma mark - Color Switch

- (IBAction)colorSettings:(UISegmentedControl *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    
    //Save the selected color segment
    switch (selectedSegmentIndex) {
        case 0:
            //Complementary colors
            [defaults setObject:@"Complementary" forKey:@"colorSettings"];
            break;
        case 1:
            //Dark colors
            [defaults setObject:@"Dark" forKey:@"colorSettings"];
            break;
        case 2:
            //No special color scheme
            [defaults setObject:@"Off" forKey:@"colorSettings"];
            break;
        default:
            break;
    }
    [self saveUserDefaults];
}

- (NSString *)getColorSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults stringForKey:@"colorSettings"];
}

#pragma mark - Social Sharing Switches
//??? Hide Social code for this version
/*

- (IBAction)sendWithTwitter:(UISegmentedControl *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    VolleyBallViewController *volleyVC = [[VolleyBallViewController alloc] init];

    
    //Save the segmented value
    switch (selectedSegmentIndex) {
        case 0:
            //Send Twitter messages
        {[defaults setObject:@"On" forKey:@"enableTwitter"];
            volleyVC.mainPageTwitterButton.enabled = TRUE;}
            break;
          case 1:
            //Don't send Twitter messages
        {[defaults setObject:@"Off" forKey:@"enableTwitter"];
            volleyVC.mainPageTwitterButton.enabled = FALSE;}
        default:
            break;
    }
    [self saveUserDefaults];
}

- (IBAction)sendWithFacebook:(UISegmentedControl *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedSegmentIndex = [sender selectedSegmentIndex];
    VolleyBallViewController *volleyVC = [[VolleyBallViewController alloc] init];

    
    //Save the segmented value
    switch (selectedSegmentIndex) {
        case 0:
        {//Send Facebook messages
            [defaults setObject:@"On" forKey:@"enableFacebook"];
            volleyVC.mainPageFacebookButton.enabled = TRUE;}
            break;
        case 1:
        {//Don't send Facebook messages
            [defaults setObject:@"Off" forKey:@"enableFacebook"];
            volleyVC.mainPageFacebookButton.enabled = FALSE;}
        default:
            break;
    }
    [self saveUserDefaults];
}

- (NSString *)getTwitterNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults stringForKey:@"enableTwitter"];
}

- (NSString *)getFacebookNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults stringForKey:@"enableFacebook"];
}
*/

#pragma mark - People Picker Methods

- (IBAction)getPhoneNumberFromAddressBook:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (void)displayPerson:(ABRecordRef)person
{
    NSString *phone = nil;
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 1) {
        phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, 1);
       //If they pick a contact, save that number
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:phone forKey:@"phoneNumberForNotification"]; 
    } else {
        //Contact didn't have a phone number on their contact.  Send alert to tell user.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone Number Error"
                                                        message:@"The contact either doesn't have a valid phone number or the app can't access the phone number.\nPlease select a different contact."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    
    CFRelease(phoneNumbers);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)showSupportView
{
    //Show the Support view
    [self performSegueWithIdentifier:@"supportView" sender:self];
}

- (void)saveUserDefaults
{
    //Save settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults synchronize]) {
        //Synchronize could't happen; show user alert and exit
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings could not be saved", nil)
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ActionName Delegate

- (void)actionNameSelected:(NSString *)actionName
{
    [self setActionName:actionName];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.actionNameVC dismissViewControllerAnimated:FALSE completion:nil];
    }
}




#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"actionNameView"]) {
        self.actionNameVC = [[ActionLabelTableViewController alloc] init];
        self.actionNameVC = segue.destinationViewController;
        self.actionNameVC.delegate = self;
        self.actionNameVC.selectedActionRow = self.actionRow;
    }
}

- (IBAction)unwindFromModalViewController:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[ActionLabelTableViewController class]]) {
        //Unwinding from Action Name VC
        self.actionNameVC = segue.sourceViewController;
        [self setActionName:self.actionNameVC.selectedActionName];
    }
}

- (void)setActionName:(NSString *)name
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Determine which Action Name row was selected prior to the segue
    if (self.actionRow == 1) {
        [defaults setObject:name forKey:@"leftActionName"];
    } else {
        [defaults setObject:name forKey:@"rightActionName"];
    }
    //Remove the row number from actionRow
    self.actionRow = 0;
    
    [self saveUserDefaults];
    
    //Refresh the popover values
    [self viewWillAppear:TRUE];

}

#pragma mark - UITableView Delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected row color so the entire row doesn't become gray when it's touched
    [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleNone];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    int actionTag = (int)cell.tag;
    
    if (actionTag == 1 || actionTag == 2) {
        self.existingLeftActionName = self.leftActionNameSelected.text;
        self.existingRightActionName = self.rightActionNameSelected.text;
        if (actionTag == 1) {
            //The left Action Name row was selected
            self.actionRow = 1;
        } else {
            //The right Action Name row was selected
            self.actionRow = 2;
        }
    } else {
        //Exit because the row was not for Action Name
        return;
    }
    
    //Action Name row was selected so segue to that VC
    [self performSegueWithIdentifier:@"actionNameView" sender:self];
    

}

#pragma mark - UITextField Phone Formatting

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
    [self.view endEditing:TRUE];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
    [textField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //calculate new length
    NSInteger moddedLength = textField.text.length-(range.length-string.length);
    
    // max size.
    if (moddedLength >= 13) {
        return NO;
    }
    
    // Reject non-number characters
    if (range.length == 0 &&![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if ([self range:range ContainsLocation:3] || [self range:range ContainsLocation:7]) {
        textField.text = [self formatPhoneString:[textField.text stringByReplacingCharactersInRange:range withString:string]];
        return NO;
    }
    
    return YES;
}

#pragma mark Phone Formatting Helpers

-(NSString*) formatPhoneString:(NSString*) preFormatted
{
    //delegate only allows numbers to be entered, so '-' is the only non-legal char.
    NSString* workingString = [preFormatted stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //insert first '-'
    if(workingString.length > 3)
    {
        workingString = [workingString stringByReplacingCharactersInRange:NSMakeRange(3, 0) withString:@"-"];
    }
    
    //insert second '-'
    if(workingString.length > 7)
    {
        workingString = [workingString stringByReplacingCharactersInRange:NSMakeRange(7, 0) withString:@"-"];
    }
    
    return workingString;
    
}

-(bool) range:(NSRange) range ContainsLocation:(NSInteger) location
{
    if(range.location <= location && range.location+range.length >= location)
    {
        return true;
    }
    
    return false;
}

#pragma clang diagnostic pop
@end
