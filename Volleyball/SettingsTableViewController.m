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
    UIBarButtonItem *saveButton;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Create bar button items and add them to the navigation bar
    saveButton = [[UIBarButtonItem alloc]
                  initWithTitle:@"Save"
                  style:UIBarButtonItemStyleBordered
                  target:self
                  action:@selector(saveSettings)];
    
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
    NSArray *barButtonItems = @[saveButton, fixedSpace, infoButton];
    self.navigationItem.rightBarButtonItems = barButtonItems;
    
    //Hide the Save button for now because nothing needs to be saved
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)saveSettings
{
    
}

- (void)showSupportView
{
    //Show the Support view
    [self performSegueWithIdentifier:@"supportView" sender:self];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    //Set the UINavigation color
    return UIStatusBarStyleLightContent;
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
    
    //Enable Save button
    self.navigationItem.rightBarButtonItem = saveButton;
    
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
    
    //Enable Save button
    self.navigationItem.rightBarButtonItem = saveButton;
    
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
