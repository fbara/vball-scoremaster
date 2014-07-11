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
@end

@implementation SettingsTableViewController
{
    //UIBarButtonItem *editSettingsButton;
    BOOL editingMode;
    BOOL changesMade;
}

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

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    self.editSettingsButton = [[UIBarButtonItem alloc]
                  initWithTitle:@"Edit"
                  style:UIBarButtonItemStyleBordered
                  target:self
                  action:@selector(saveSettings:)];
    
    UIImage *image = [UIImage imageNamed:@"info.png"];
    
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
    NSArray *barButtonItems = @[self.editSettingsButton, fixedSpace, infoButton];
    self.navigationItem.rightBarButtonItems = barButtonItems;
    
    //Set the switch if messages will be sent
    if ([[self getSendNotifications] isEqualToString:@"On"]) {
        [self.sendNotificationSwitch setSelectedSegmentIndex:0];
    } else {
        [self.sendNotificationSwitch setSelectedSegmentIndex:1];
    }
    
    //When the screen loads, we're not in editing mode nor have changes been made
    editingMode = NO;
    changesMade = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //Get the saved score background colors
    self.homeTeamColor.backgroundColor = [self getSavedScoreColors:@"homeTeamColor"];
    self.visitingTeamColor.backgroundColor = [self getSavedScoreColors:@"visitorTeamColor"];
    
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
    [self.view setNeedsDisplay];

}

- (void)viewWillDisappear:(BOOL)animated
{
    //Save our settings before the scene goes away
    [self saveUserDefaults];
    [super viewWillDisappear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    //Set the UINavigation color
    return UIStatusBarStyleLightContent;
}

- (BOOL)canBecomeFirstResponder { return YES; }

#pragma mark - Save Settings

/*!
 *  Save the settings
 *
 *  @param sender The param is not used
 */
- (IBAction)saveSettings:(id)sender
{
    if (!editingMode) {
        //Indicate we're now in editing mode
        editingMode = YES;
        
        //Button starts out as 'Edit' and should be changed to 'Done'
        self.editSettingsButton.title = @"Save";

        //Enable UI elements
        [self enableUIObjects];
        
        //Hide left 'back' button so they can't back out without hitting
        //'done' button first
        [self.navigationItem setHidesBackButton:YES animated:YES];
        
        
    } else {
        //No longer in editing mode
        editingMode = NO;
        changesMade = NO;
        
        //Put button label back to 'Edit'
        self.editSettingsButton.title = @"Edit";
        
        //Disable UI elements
        [self disableUIObjects];
        
        //Save the colors regardless if they were changed or not
        [self saveScoreColors];
        //Save Action names
        [self saveActionNames:self.firstActionNameSelected.text
                   secondName:self.secondActionNameSelected.text];
        //Save player name and SMS number
        [self savePlayerName:self.nameOfPlayer.text
             saveNotifyPhone:self.notificationName.text];

        //Show the 'back' button again so they can leave this screen
        [self.navigationItem setHidesBackButton:NO animated:YES];

    }
}

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
 *  @param firstActionName  The top Action name
 *  @param secondActionName The bottom Action name
 */
- (void)saveActionNames:(NSString *)firstActionName secondName:(NSString *)secondActionName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([firstActionName length] > 1) {
        
        [defaults setObject:firstActionName forKey:@"firstActionName"];
    } else {
        [defaults setObject:@"SPIKE" forKey:@"firstActionName"];
    }
    
    if ([secondActionName length] > 1) {
        
        [defaults setObject:secondActionName forKey:@"secondActionName"];
    } else {
        [defaults setObject:@"ACE" forKey:@"secondActionName"];
    }

}

/*!
 *  Returns the Action names from user defaults
 *  and populates the labels on the main screen
 */
- (void)getActionNames
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempName;
    tempName = [defaults stringForKey:@"firstActionName"];
    
    if ([tempName length] < 1) {
        self.firstActionNameSelected.text = @"SPIKE";
    } else {
       //tempName = [defaults stringForKey:@"firstActionName"];
        self.firstActionNameSelected.text = tempName;
    }
    
    tempName = [defaults stringForKey:@"secondActionName"];
    
    if ([tempName length] < 1) {
        self.secondActionNameSelected.text = @"ACE";
    } else {
        //tempName = [defaults stringForKey:@"secondActionName"];
        self.secondActionNameSelected.text = tempName;
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
    
    //Indicate changes were made
    changesMade = YES;
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
    
    //Indicate changes were made
    changesMade = YES;
    
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

#pragma mark - Enable/Disable UI

- (void)enableUIObjects
{
    self.homeTeamColor.enabled = TRUE;
    self.visitingTeamColor.enabled = TRUE;
    self.sendNotificationSwitch.enabled = TRUE;
    self.addPhoneNumberButton.enabled = TRUE;
//    self.firstActionNameSelected.enabled = TRUE;
//    self.secondActionNameSelected.enabled = TRUE;
    self.nameOfPlayer.enabled = TRUE;
    self.notificationName.enabled = TRUE;

}

- (void)disableUIObjects
{
    self.homeTeamColor.enabled = FALSE;
    self.visitingTeamColor.enabled = FALSE;
    self.sendNotificationSwitch.enabled = FALSE;
    self.addPhoneNumberButton.enabled = FALSE;
//    self.firstActionNameSelected.enabled = FALSE;
//    self.secondActionNameSelected.enabled = FALSE;
    self.nameOfPlayer.enabled = FALSE;
    self.notificationName.enabled = FALSE;

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

//#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 4;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 2;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

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
            //self.firstActionNameSelected = (UILabel *)tempString;
            [defaults setObject:tempString forKey:@"firstActionName"];
        } else {
            //self.secondActionNameSelected = (UILabel *)tempString;
            [defaults setObject:tempString forKey:@"secondActionName"];
        }
        //Remove the row number from actionRow
        self.actionRow = 0;
        
        [self saveUserDefaults];
    }
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected row color so the entire row doesn't become gray when it's touched
    if (editingMode) {
        [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleNone];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        int actionTag = cell.tag;
        
        if (actionTag == 1 || actionTag == 2) {
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
    } else {
        return;
    }


}


@end
