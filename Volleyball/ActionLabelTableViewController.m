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
    
    //Find the path of the ActionNames plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ActionNames" ofType:@"plist"];
    
    //Load the file and read the data into an array
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.actionNames = [dict objectForKey:@"ActionNames"];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
    [self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView cellForRowAtIndexPath:indexPath].highlighted = NO;
    
    return indexPath;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *name;
    //Which side, left or right, is the user acting on?
    switch (self.selectedActionRow) {
        case 1:
            //The user is on the left side
            name = [defaults stringForKey:@"leftActionName"];
            break;
        case 2:
            //The user is on the right side
            name = [defaults stringForKey:@"rightActionName"];
            break;
        default:
            break;
    }
    int row = [self getRowForName:name];
    NSIndexPath *initialIndex = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView selectRowAtIndexPath:initialIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView willSelectRowAtIndexPath:initialIndex];
    [self tableView:self.tableView didSelectRowAtIndexPath:initialIndex];
    
    
    //Load the row the user has already selected & put a checkmark by it
}

- (int)getRowForName:(NSString *)selectedName
{
    //Return the index row for the name passed in
    if ([selectedName isEqualToString:@"SPIKE"]) {
        return 0;
    } else if ([selectedName isEqualToString:@"DIG"])
        return 1;
    else if ([selectedName isEqualToString:@"ACE"])
        return 2;
    else if ([selectedName isEqualToString:@"BLOCK"])
        return 3;
    else if ([selectedName isEqualToString:@"SET"])
        return 4;
    else {
        return 5;
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.actionNames count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.actionNames objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
   // select new
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedActionName = cell.textLabel.text;
    
    //If on the iPad, selecting a row will take you out of this view
    //[self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
    

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //Set the header of the table with instructions to save changes
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull] ;
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.font = [UIFont systemFontOfSize:14];
    sectionHeader.textColor = [UIColor darkGrayColor];
    sectionHeader.text = @"   SELECT AN ACTION NAME THEN TAP 'SAVE'";
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
