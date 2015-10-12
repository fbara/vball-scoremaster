//
//  ActionLabelTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/7/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "ActionLabelTableViewController.h"
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
//#import "GAIDictionaryBuilder.h"
#import "SWRevealTableViewCell.h"
//#import <ChameleonFramework/Chameleon.h>
#import "Chameleon.h"

@interface ActionLabelTableViewController () <SWRevealTableViewCellDelegate, SWRevealTableViewCellDataSource>
{
	NSIndexPath *_revealingCellIndexPath;
	NSInteger _sectionTitleRowCount;
}

#define IS_IPAD() [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

@end

@implementation ActionLabelTableViewController  {
    BOOL firstTimeShown;
	NSArray *allActionNames;
}

typedef enum
{
	SectionTitle = 0,
	SectionImage,
	SectionsCount,
} Sections;


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
	
//TODO: Add '+' to add rows
	// Create bar button item and add them to the navigation bar
	UIBarButtonItem *addNewName = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				target:self
																				action:@selector(addNewActionName)];
	UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																		  target:self
																		  action:@selector(saveActionName)];
	
	NSArray *barButtonItems = @[save, addNewName];
	self.navigationItem.rightBarButtonItems = barButtonItems;

}

-(void)addNewActionName {
	NSLog(@"New name");
}

-(void)saveActionName {
	
}

- (NSIndexPath*)tableView:(UITableView*)tableView
    willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* oldIndex = [self.tableView indexPathForSelectedRow];
    [self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView cellForRowAtIndexPath:indexPath].highlighted = NO;
	[self.tableView cellForRowAtIndexPath:indexPath].editing = YES;

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

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"Identifier";
	SWRevealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.delegate = self;
	cell.dataSource = self;
	
	if (indexPath.section == SectionTitle) {
		cell.cellRevealMode = SWCellRevealModeReversedWithAction;
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
	if (indexPath.section == SectionImage) {
		cell.cellRevealMode = SWCellRevealModeNormal;
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:cellIdentifier];
//    }
//    cell.textLabel.text = [self.actionNames objectAtIndex:indexPath.row];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
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
		
		UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeader.frame.size.width, sectionHeader.frame.size.height)];
		UIButton *headerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
		headerBtn.backgroundColor = [UIColor clearColor];
		headerBtn.opaque = NO;
		headerBtn.frame = CGRectMake(10.0, 0.0, 100.0, 30.0);
		[headerBtn setTitle:NSLocalizedString(@"Add", @"Add new Action Name") forState:UIControlStateNormal];
		headerBtn.titleLabel.textColor = [UIColor blackColor];
		[headerBtn addTarget:self action:@selector(addNewActionName) forControlEvents:UIControlEventTouchUpInside];
		[customView addSubview:headerBtn];
		return customView;
    } else {
        sectionHeader.text = NSLocalizedString(@"   SELECT AN ACTION NAME THEN TAP 'SAVE'", @"Tap on the Action Name for your player, then tap Save");
    }
    return sectionHeader;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark - SWReveal Row Button Actions
-(NSArray *)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell {
	
	NSArray *items = nil;
	NSIndexPath *indexPath = [self.tableView indexPathForCell:revealTableViewCell];
	NSInteger section = indexPath.section;
	
	if (section == SectionTitle) {
		SWCellButtonItem *itemDelete1 = [SWCellButtonItem itemWithTitle:NSLocalizedString(@"Delete", @"Delete ActionName")
															   handler:^(SWCellButtonItem *itemDelete, SWRevealTableViewCell *cell) {
																   _revealingCellIndexPath = [self.tableView indexPathForCell:cell];
																   [self performRowDeleteAction:itemDelete];
																   return NO;
															   }];
		itemDelete1.backgroundColor = [UIColor flatRedColor];
		itemDelete1.tintColor = [UIColor flatWhiteColor];
		itemDelete1.width = 75;
		
		SWCellButtonItem *itemRename2 = [SWCellButtonItem itemWithTitle:NSLocalizedString(@"Rename", @"Rename")
																handler:^(SWCellButtonItem *itemRename, SWRevealTableViewCell *cell){
																	_revealingCellIndexPath = [self.tableView indexPathForCell:cell];
																	[self performRowRenameAction:itemRename];
																	return NO;
																}];
		itemRename2.backgroundColor = [UIColor blueColor];
		itemRename2.tintColor = [UIColor flatWhiteColor];
		itemRename2.width = 50;
		
		items = @[itemDelete1, itemRename2];
	}
	return items;
}

#pragma mark - Row Actions

/*!
 *  @author Me, 10-01-15 17:10
 *
 *  Deletes the current row
 */
-(void)performRowDeleteAction:(SWCellButtonItem *)item {
	_sectionTitleRowCount -= 1;
	[self.tableView deleteRowsAtIndexPaths:@[_revealingCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

/*!
 *  @author Me, 10-01-15 17:10
 *
 *  Renames the current row's Action Name
 */
-(void)performRowRenameAction:(SWCellButtonItem *)item {
//TODO: Add rename code
	NSLog(NSLocalizedString(@"\nRename tapped", @"\nRename tapped"));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
