//
//  SettingsTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ActionLabelTableViewController.h"

@interface SettingsTableViewController ()

@property int actionRow;
@property NSString *existingRightActionName;
@property NSString *existingLeftActionName;

@end

@implementation SettingsTableViewController
{
    NSString *firstStartTime;
}



#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
        
    UIImage *image = [UIImage imageNamed:@"Info44.png"];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]
                                   initWithImage:image
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(showSupportView)];

    NSArray *barButtonItems = @[infoButton];
    self.navigationItem.rightBarButtonItems = barButtonItems;
    
    //Set the switch if messages will be sent
    if ([[self getSendNotifications] isEqualToString:@"On"]) {
        [self.sendNotificationSwitch setSelectedSegmentIndex:0];
    } else {
        [self.sendNotificationSwitch setSelectedSegmentIndex:1];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //Is this the first time running this VC?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    firstStartTime = [defaults stringForKey:@"firstStartTime"];
    
    if ([firstStartTime length] < 1) {
        //First time starting this VC. Set initial score background colors
        self.homeTeamColor.backgroundColor = [UIColor blueColor];
        self.visitingTeamColor.backgroundColor = [UIColor orangeColor];
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
    
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    //Save our settings before the scene goes away
    [self saveScoreColors];
    [self savePlayerName:self.nameOfPlayer.text saveNotifyPhone:self.notificationName.text];
    [self saveActionNames:self.leftActionNameSelected.text secondName:self.rightActionNameSelected.text];
    [self notificationSwitch:self.sendNotificationSwitch];

    [super viewWillDisappear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    //Set the UINavigation color
    return UIStatusBarStyleLightContent;
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
    UIColor *homeButtonColor;
    homeButtonColor = [self getRandomColor];
    self.homeTeamColor.backgroundColor = homeButtonColor;
}

/*!
 * @discussion The background color of the visiting team's score
 * @param sender This param is not used.
 */
- (IBAction)visitingTeamBackgroundColor:(id)sender
{
    //Change the button background color each time the button is tapped
    UIColor *visitingButtonColor;
    visitingButtonColor = [self getRandomColor];
    self.visitingTeamColor.backgroundColor = visitingButtonColor;
}

- (UIColor *)getRandomColor
{
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    int a = arc4random() % 255;
    
    UIColor *color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a/1.0];
    return color;
}

#pragma mark - Notificaion Switch
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
    } else {
        phone = @"None";
    }
    
    self.notificationName.text = phone;
    
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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"actionNameView"]) {
        ActionLabelTableViewController *actionTVC = (ActionLabelTableViewController *)segue.destinationViewController;
        actionTVC.selectedActionRow = self.actionRow;
    }
}

- (IBAction)unwindFromModalViewController:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[ActionLabelTableViewController class]]) {
        //Unwinding from Action Name VC
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        ActionLabelTableViewController *actionNameTVC = segue.sourceViewController;
        NSString *tempString = actionNameTVC.selectedActionName;
        //Determine which Action Name row was selected prior to the segue
        if (self.actionRow == 1) {
            [defaults setObject:tempString forKey:@"leftActionName"];
        } else {
            [defaults setObject:tempString forKey:@"rightActionName"];
        }
        //Remove the row number from actionRow
        self.actionRow = 0;
        
        [self saveUserDefaults];
    }
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
            //The first Action Name row was selected
            self.actionRow = 1;
        } else {
            //The second Action Name row was selected
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


@end
