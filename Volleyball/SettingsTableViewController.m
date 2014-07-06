//
//  SettingsTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()


@end

@implementation SettingsTableViewController
{
    UIBarButtonItem *editSettingsButton;
    BOOL editingMode;
    BOOL changesMade;
    
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    editSettingsButton = [[UIBarButtonItem alloc]
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
    NSArray *barButtonItems = @[editSettingsButton, fixedSpace, infoButton];
    self.navigationItem.rightBarButtonItems = barButtonItems;
    
    //When the screen loads, we're not in editing mode nor have changes been made
    editingMode = NO;
    changesMade = NO;
    
    //Load the saved settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults stringForKey:@"enableNotifications"] isEqualToString:@"On"]) {
        //User wants notifications so set switch to ON and enable all text & label fields
        [self.notificationSwitch setOn:YES];
        for (UILabel *label in self.settingsLabels) {
            label.enabled = YES;
        }
        for (UITextField *text in self.notificationTextEntries) {
            text.enabled = YES;
        }
    } else {
        //User doesn't want notifications so set switch to OFF and disable notification fields
        [self.notificationSwitch setOn:NO];
        for (UITextField *text in self.notificationTextEntries) {
            text.enabled = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.homeTeamColor.backgroundColor = [self getSavedScoreColors:@"homeTeamColor"];
    self.visitingTeamColor.backgroundColor = [self getSavedScoreColors:@"visitorTeamColor"];
}

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


-(UIStatusBarStyle)preferredStatusBarStyle
{
    //Set the UINavigation color
    return UIStatusBarStyleLightContent;
}

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
        editSettingsButton.title = @"Done";

        //Enable UI elements
        self.homeTeamColor.enabled = TRUE;
        self.visitingTeamColor.enabled = TRUE;
        
        
        //Hide left 'back' button so they can't back out without hitting
        //'done' button first
        self.navigationItem.leftBarButtonItem.enabled = nil;
        
        
    } else {
        //No longer in editing mode
        editingMode = NO;
        
        //Put button label back to 'Edit'
        editSettingsButton.title = @"Edit";
        
        //Disable UI elements
        self.homeTeamColor.enabled = FALSE;
        self.visitingTeamColor.enabled = FALSE;
        
        //Save the colors regardless if they were changed or not
        [self saveScoreColors];
        
        //Show the 'back' button again so they can leave this screen
        self.navigationItem.leftBarButtonItem.enabled = YES;

    }

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

- (void)showSupportView
{
    //Show the Support view
    [self performSegueWithIdentifier:@"supportView" sender:self];
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
    
    UIColor *color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    return color;
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


//#pragma mark - Table view delegate
//
//// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    // Navigation logic may go here, for example:
////    // Create the next view controller.
////    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
////    
////    // Pass the selected object to the new view controller.
////    
////    // Push the view controller.
////    [self.navigationController pushViewController:detailViewController animated:YES];
//    
//    //Change the selected row color so the entire row doesn't become gray when it's touched
//    if (!editingMode) {
//        [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleNone];
//
//    }
//
//}


@end
