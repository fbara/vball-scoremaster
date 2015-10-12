//
//  ActionLabelTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/7/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "ActionLabelTableViewController.h"
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
//#import "GAIDictionaryBuilder.h"
#import <GoogleAnalytics/GAITracker.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAI.h>


@implementation ActionLabelTableViewController {
    BOOL firstTimeShown;
}

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

    // Find the path of the ActionNames plist
    NSString* path =
        [[NSBundle mainBundle] pathForResource:@"ActionNames" ofType:@"plist"];

    // Load the file and read the data into an array
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.actionNames = [dict objectForKey:@"ActionNames"];

    // Indicate this is the first time this view is seen
    firstTimeShown = YES;
}

- (NSIndexPath*)tableView:(UITableView*)tableView
    willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* oldIndex = [self.tableView indexPathForSelectedRow];
    [self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView cellForRowAtIndexPath:indexPath].highlighted = NO;

    return indexPath;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* name;
    // Which side, left or right, is the user acting on?
    switch (self.selectedActionRow) {
    case 1:
        // The user is on the left side
        name = [defaults stringForKey:@"leftActionName"];
        break;
    case 2:
        // The user is on the right side
        name = [defaults stringForKey:@"rightActionName"];
        break;
    default:
        break;
    }
    int row = [self getRowForName:name];
    NSIndexPath* initialIndex = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView selectRowAtIndexPath:initialIndex
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView willSelectRowAtIndexPath:initialIndex];
    [self tableView:self.tableView didSelectRowAtIndexPath:initialIndex];

    // Load the row the user has already selected & put a checkmark by it
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Setup Google Analytics tracker for this screen
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker set:kGAIScreenName value:@"Action Names"];
	//Change to createScreenView because createAppView is deprecated
	//[tracker send:[[GAIDictionaryBuilder createAppView] build]];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (int)getRowForName:(NSString*)selectedName
{
    // Return the index row for the name passed in
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
    else if ([selectedName isEqualToString:@"Pass"])
        return 5;
    else {
        return 0;
    }
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.actionNames count];
    return count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"Identifier";
    UITableViewCell* cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.actionNames objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // select new
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (IS_IPAD()) {
        // Is this the first time this view was shown?
        if (firstTimeShown) {
            // Show the existing selection and indicate we've been thru this path
            // before
            firstTimeShown = NO;
        } else {
            //if ([self.delegate respondsToSelector:@selector(actionNameSelected:)]) {
                // Prepare to call the delegate with the selected row name
                self.selectedActionName = cell.textLabel.text;
                [self.delegate actionNameSelected:self.selectedActionName];
            //}
        }
    } else {
        // Should only hit this if on iPhone
        self.selectedActionName = cell.textLabel.text;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	//For iPad only; there's no footer displayed on the iPhone
	UILabel *sectionFooter = [[UILabel alloc] initWithFrame:CGRectNull];
	sectionFooter.backgroundColor = [UIColor clearColor];
	sectionFooter.font = [UIFont systemFontOfSize:12];
	sectionFooter.textColor = [UIColor darkGrayColor];
	if (IS_IPAD()) {
		sectionFooter.text = NSLocalizedString(@"   Tap anywhere off this popup to dismiss", @"Tap the screen anywhere away from this popup to dismiss the window");
	} else {
		sectionFooter.text = @"";
	}	
	return sectionFooter;
}

- (UIView*)tableView:(UITableView*)tableView
    viewForHeaderInSection:(NSInteger)section
{
    // Set the header of the table with instructions to save changes
    UILabel* sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull];
    sectionHeader.backgroundColor = [UIColor clearColor];
	sectionHeader.font = [UIFont systemFontOfSize:14];
    sectionHeader.textColor = [UIColor darkGrayColor];
    if (IS_IPAD()) {
		sectionHeader.text = NSLocalizedString(@"   SELECT AN ACTION NAME", @"Tap on the Action Name for your player");
    } else {
        sectionHeader.text = NSLocalizedString(@"   SELECT AN ACTION NAME THEN TAP 'SAVE'", @"Tap on the Action Name for your player, then tap Save");
    }
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
