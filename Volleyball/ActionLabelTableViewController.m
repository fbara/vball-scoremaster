//
//  ActionLabelTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/7/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "ActionLabelTableViewController.h"

@interface ActionLabelTableViewController ()

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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
   // select new
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedActionName = cell.textLabel.text;

}

@end
