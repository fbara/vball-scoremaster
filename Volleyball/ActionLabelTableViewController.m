//
//  ActionLabelTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/7/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "ActionLabelTableViewController.h"

@interface ActionLabelTableViewController ()

@property (retain) NSIndexPath *lastSelected;

@end

@implementation ActionLabelTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Put a checkmark on the row that's already selected.
    //We get this from the SettingsTable VC
//TODO: Add code to put checkmark on row
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    [self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    return indexPath;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//
//}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.lastSelected==indexPath) return; // nothing to do
//    
//    // deselect old
//    UITableViewCell *old = [self.tableView cellForRowAtIndexPath:self.lastSelected];
//    old.accessoryType = UITableViewCellAccessoryNone;
//    [old setSelected:FALSE animated:TRUE];
//    
//    // select new
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    [cell setSelected:TRUE animated:TRUE];
//    
//    // keep track of the last selected cell
//    self.lastSelected = indexPath;
    self.selectedActionName = cell.textLabel.text;
    
    //Perform a segue to go back to the SettingsTableViewController, passing the row selected
    //[self performSegueWithIdentifier:@"actionSelected" sender:self.selectedActionName];
}

@end
