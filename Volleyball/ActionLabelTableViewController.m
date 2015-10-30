//
//  ActionLabelTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/7/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "ActionLabelTableViewController.h"
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAITracker.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAI.h>

@interface ActionLabelTableViewController ()

@property (weak, nonatomic) NSString *actionNameToAdd;
@property (strong, nonatomic) NSMutableArray *actionNamesList;

@end

@implementation ActionLabelTableViewController {
    BOOL firstTimeShown;
}

-(NSMutableArray *)actionNamesList {
	if (_actionNamesList) {
		_actionNamesList = [[NSMutableArray alloc] initWithObjects:@"Spike", @"Dig", @"Ace", @"Block", @"Set", @"Pass" , nil];
	}
	return _actionNamesList;
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

	

    // Indicate this is the first time this view is seen
    firstTimeShown = YES;
	
	//Setup bar button items
	UIBarButtonItem *saveActionNames = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																					 target:self
																					 action:@selector(returnToSettings:)];
	UIBarButtonItem *addActionName = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				   target:self
																				   action:@selector(addNewActionName:)];
	
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

- (UIView*)tableView:(UITableView*)tableView
    viewForHeaderInSection:(NSInteger)section
{
    // Set the header of the table with instructions to save changes
    UILabel* sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull];
    sectionHeader.backgroundColor = [UIColor clearColor];
	sectionHeader.font = [UIFont systemFontOfSize:14];
    sectionHeader.textColor = [UIColor darkGrayColor];
	sectionHeader.text = NSLocalizedString(@"   SELECT AN ACTION NAME THEN TAP 'SAVE'", @"Tap on the Action Name for your player, then tap Save");

    return sectionHeader;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		//Remove object from source
		
	}
}

#pragma mark - Move Rows

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark - Bar Button Items

-(IBAction)returnToSettings:(id)sender {
	//Perform unwind segue and return to the Settings scene
	[self performSegueWithIdentifier:@"unwindFromModalViewController" sender:self];
}

-(void)addNewActionName:(NSString *)newName {
	//Create a new Action Name
}

-(void)deleteActionName:(NSIndexPath *)indexPath {
	//Delete an existing Action Name
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
