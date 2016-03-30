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
#import <ChameleonFramework/Chameleon.h>
#import <TSMessages/TSMessageView.h>
#import <BTBalloon/BTBalloon.h>
#import <GBVersionTracking/GBVersionTracking.h>

@interface ActionLabelTableViewController () <UITextFieldDelegate, TSMessageViewProtocol, UIPopoverPresentationControllerDelegate> {
	BOOL firstTimeShown, rowCanSlide, rowChecked;
	NSUserDefaults *defaults;
	NSIndexPath *m_currentIndexPath, *selectedIndexPath;
	SESlideTableViewCell *selectedCell;
}
@property (strong, nonatomic)NSMutableArray *actionNamesList;
@property (nonatomic, strong)UIPreviewActionGroup *previewActions;

@end
@implementation ActionLabelTableViewController

-(NSMutableArray *)actionNamesList {
	//Create array of ActionNames
	if (!_actionNamesList) {
		if (firstTimeShown) {
			_actionNamesList = [[NSMutableArray alloc] initWithObjects:@"Spike", @"Dig", @"Ace", @"Block", @"Set", @"Pass", nil];
			defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:_actionNamesList forKey:@"ActionNames"];
		} else {
		//Names don't exist yet, create them from standard defaults
		defaults = [NSUserDefaults standardUserDefaults];
		_actionNamesList = [[NSMutableArray alloc] init];
		_actionNamesList = [[defaults objectForKey:@"ActionNames"] mutableCopy];
		}
	}
	return _actionNamesList;
}

#pragma mark - View Load/Unload

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
	defaults = [NSUserDefaults standardUserDefaults];
	
	//Load default ActionNames if array doesn't yet exist
	if (!self.actionNamesList) {
		self.actionNamesList = [defaults objectForKey:@"ActionNames"];
	}
	//Add long press gesture for moving rows
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
																							action:@selector(longPressGesture:)];
	[self.tableView addGestureRecognizer:longPress];
	
    // Indicate this is the first time this view is seen
    
    firstTimeShown = YES;
	rowCanSlide = YES;
	rowChecked = NO;
	[TSMessage setDelegate:self];
	self.tableView.tintColor = FlatBlue;
	//Check if this is the first time the user is seeing this view
	[self checkForFirstTimeInView];
	
	//There's a Save button showing up and I can't figure out where it comes from.
	//Hide the Save button for now. Backing out of view will save setting.
	self.navigationItem.rightBarButtonItem = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Setup Google Analytics tracker for this screen
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker set:kGAIScreenName value:@"Action Labels"];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewWillDisappear:(BOOL)animated {
	
	//Save the Action Names
	[defaults setObject:self.actionNamesList forKey:@"ActionNames"];
	
	//Check if there are no rows with checkmarks
	if (!rowChecked) {
		//No rows found; put a check on the first row in the table
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	}
	//Clear the selected row indexPath
	selectedIndexPath = nil;
    	
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
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
	//Get the index of the current Action Name from the list of names
	NSUInteger row = [self.actionNamesList indexOfObject:name];
	if (row == NSNotFound) {
		//There's no match in the array so select first row
		row = 0;
	}
	NSIndexPath* initialIndex = [NSIndexPath indexPathForRow:row inSection:0];
	[self.tableView selectRowAtIndexPath:initialIndex
								animated:NO
						  scrollPosition:UITableViewScrollPositionNone];
	
	[self tableView:self.tableView didSelectRowAtIndexPath:initialIndex];

}

/*!
 *  @author Me, 11-05-15 07:11
 *
 *  Check if this is the first time the user has ever seen this view.
 *  If so, show them how to use the sliding cells.
 */
-(void)checkForFirstTimeInView {
	if ([GBVersionTracking isFirstLaunchEver] || [GBVersionTracking isFirstLaunchForVersion] ) {
		if ([defaults boolForKey:@"firstTimeEver"]) {
			//Show BTBalloon with info on rows
			NSString *title = @"Swipe on the row!\nYou can add, rename, and delete rows. Just swipe a row to see the buttons!";
			[BTBalloon appearance].textFont = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
	//if (IS_IPAD()) {
		//Show after a .5 second delay. The balloon will be presented after the popover so I have to delay
		//it's presentation to make sure it shows up in front of the popover.
		[[BTBalloon sharedInstance] showWithTitle:title
											image:[UIImage imageNamed:@"Swipe-Left-White"]
									 anchorToView:selectedCell
									  buttonTitle:@"Continue"
								   buttonCallback:^{
                                       [defaults setBool:FALSE forKey:@"firstTimeEver"];
									   [[BTBalloon sharedInstance] hideWithAnimation:YES];
										}
									   afterDelay:0.5];

		}
	}
}


#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.actionNamesList count];
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	SESlideTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	//Check if cell has been slid open
	if ([cell slideState] == SESlideTableViewCellSlideStateCenter) {
		//Cell is open, prevent an accessory checkmark
		NSIndexPath* oldIndex = [self.tableView indexPathForSelectedRow];
		[self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
		[self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		[self.tableView cellForRowAtIndexPath:indexPath].highlighted = NO;
		
		return indexPath;
	} else {
		//Cell is closed, ok to add checkmark
		return indexPath;
	}
	
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"Identifier";
	SESlideTableViewCell *cell = (SESlideTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[SESlideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.delegate = self;
		//Show Delete first, then Rename
		[cell addRightButtonWithText:NSLocalizedString(@"Rename", @"Rename the Action Name row")
						   textColor:FlatWhite
					 backgroundColor:FlatBlue];
		[cell addRightButtonWithText:NSLocalizedString(@"New", @"Add new Action Name row")
						   textColor:FlatBlack
					 backgroundColor:FlatGreen];
		[cell addRightButtonWithText:NSLocalizedString(@"Delete", @"Delete Action Name table row")
						   textColor:FlatWhite
					 backgroundColor:FlatRed];
		
		
		cell.textLabel.text = [self.actionNamesList objectAtIndex:indexPath.row];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	

    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (selectedIndexPath != indexPath) {
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	} else {
		return;
	}
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [defaults setBool:FALSE forKey:@"firstTimeEver"];
	// select new row
    SESlideTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	//Check if use accidentally tapped a row that was slid open
	if (cell.slideState != SESlideTableViewCellSlideStateCenter) {
		//Don't save this cell selection, throw it out and return
		return;
	}
	//User did not tap on an open cell, continue with row selection
	rowChecked = YES;
	//Save the selected cell in case the user tries to delete it
	selectedCell = cell;
	//Add the checkmark
	[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	selectedIndexPath = indexPath;
    NSString *selectedName = nil;
	//Save the selected row to the left or right?
	switch (self.selectedActionRow) {
	case 1:
		//Left side
		[defaults setObject:cell.textLabel.text forKey:@"leftActionName"];
        selectedName = @"leftActionName";
		break;
	case 2:
		//Right side
		[defaults setObject:cell.textLabel.text forKey:@"rightActionName"];
        selectedName = @"rightActionName";
		break;
	default:
			break;
	}
	
    if (IS_IPAD()) {
        // Is this the first time this view was shown?
        if (firstTimeShown) {
            // Show the existing selection and indicate we've been thru this path before
            firstTimeShown = NO;
        } else {
			// Call the delegate
			//All this does now is allow the Action Name table to be dismissed on iPad
			[self.delegate actionNameSelected:@"Nothing"];
        }
    }
    [defaults setInteger:self.selectedActionRow forKey:@"updatedActionNumber"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateActionNames" object:self];

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

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    // Set the header of the table with instructions to save changes
    UILabel* sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull];
    sectionHeader.backgroundColor = [UIColor clearColor];
	sectionHeader.font = [UIFont systemFontOfSize:14];
    sectionHeader.textColor = [UIColor darkGrayColor];
	
	sectionHeader.text = NSLocalizedString(@"   SELECT AN ACTION NAME", @"Table header, tap on the Action Name for your player");
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	//Don't allow the user to delete the last row of the table
	if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
		return YES;
	}
	//Allow deleting all other rows
	return YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	//When the table is scrolled, close any open cells
	SESlideTableViewCell *cell = [self.tableView cellForRowAtIndexPath:m_currentIndexPath];
	rowCanSlide = YES;
	[cell setSlideState:SESlideTableViewCellSlideStateCenter animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark - Long Press Gesture
-(IBAction)longPressGesture:(id)sender {
	UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
	UIGestureRecognizerState state = longPress.state;
	
	CGPoint location = [longPress locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
	
	static UIView *snapshot = nil; //snapshot of the row the user is moving
	static NSIndexPath *sourceIndexPath = nil; //initial indexPath, where gesture begins
	
	switch (state) {
		case UIGestureRecognizerStateBegan: {
			if (indexPath) {
				sourceIndexPath = indexPath;
				
				UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
				
				//Take a snapshot of the selected row
				snapshot = [self customSnapshotFromView:cell];
				
				//Add the snapshot as a subview, centered at cell's center
				__block CGPoint center = cell.center;
				snapshot.center = center;
				snapshot.alpha = 0.0;
				[self.tableView addSubview:snapshot];
				[UIView animateWithDuration:0.25 animations:^{
					//Offset for gesture location
					center.y = location.y;
					snapshot.center = center;
					snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
					snapshot.alpha = 0.98;
					cell.alpha = 0.0;
					
				} completion:^(BOOL finished){
					cell.hidden = YES;
				}];
			}
			break;
		}
			
		case UIGestureRecognizerStateChanged: {
			CGPoint center = snapshot.center;
			center.y = location.y;
			snapshot.center = center;
			
			//Is destination valid and is it different from source?
			if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
				//Update data source
				[self.actionNamesList exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
				//Move the rows
				[self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
				//Update the source so it's in sync with the UI
				sourceIndexPath = indexPath;
			}
			break;
		}
		default: {
			//Clean up
			SESlideTableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
			cell.hidden = NO;
			cell.alpha = 0.0;
			
			[UIView animateWithDuration:0.25 animations:^{
				snapshot.center = cell.center;
				snapshot.transform = CGAffineTransformIdentity;
				snapshot.alpha = 0.0;
				cell.alpha = 1.0;
				
			} completion:^(BOOL finished) {
				sourceIndexPath = nil;
				[snapshot removeFromSuperview];
				snapshot = nil;
			}];
			
			break;
		}
	}
}

- (IBAction)resetActionNames:(UIBarButtonItem *)sender {
	//Resets the ActionNames back to the default list
	NSString *title = NSLocalizedString(@"Default Action Names", @"Message box title to reset Action Names to default");
	NSString *msg = NSLocalizedString(@"Please confirm you want to reset the Action Names to their default values.", @"Message box asking for verification to reset the Action Names.");
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
																   message:msg
															preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"Confirm selection button") style:UIAlertActionStyleDefault
											   handler:^(UIAlertAction * action) {
												   self.actionNamesList = [[NSMutableArray alloc] initWithObjects:@"Spike", @"Dig", @"Ace", @"Block", @"Set", @"Pass", nil];
												   dispatch_async(dispatch_get_main_queue(), ^{
													   [self.tableView reloadData];
												   });
											   }];
						 
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
												   handler:^(UIAlertAction * action) {
													   //User tapped Cancel, dismiss alert
													   [alert dismissViewControllerAnimated:YES completion:nil];
												   }];

	[alert addAction:ok];
	[alert addAction:cancel];
	[self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - Gesture Recognizer Helper

//@brief returns a customized snapshot of a given view
-(UIView *)customSnapshotFromView:(UIView *)inputView {
	
	//Make an image from the input view
	UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
	[inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//Create an image view
	UIView *snapshot = [[UIImageView alloc] initWithImage:image];
	snapshot.layer.masksToBounds = NO;
	snapshot.layer.cornerRadius = 0.0;
	snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
	snapshot.layer.shadowRadius = 5.0;
	snapshot.layer.shadowOpacity = 0.4;
	
	return snapshot;
	
}

#pragma mark - SESlideTableViewCell Delegate

/*!
 *  @author Me, 11-08-15 11:11
 *
 *  Called when user taps on one of the cell buttons.  All cell button actions start here.
 *
 *  @param cell        SESlideTableViewCell The cell/row that was tapped.
 *  @param buttonIndex NSInteger Number that represents the index of the button that was tapped.
 */
-(void)slideTableViewCell:(SESlideTableViewCell *)cell didTriggerRightButton:(NSInteger)buttonIndex {
	NSIndexPath *path = [self.tableView indexPathForCell:cell];
	defaults = [NSUserDefaults standardUserDefaults];
	NSString *currentRight = [defaults objectForKey:@"rightActionName"];
	NSString *currentLeft = [defaults objectForKey:@"leftActionName"];
	BOOL usedName = ([cell.textLabel.text isEqualToString:currentRight] || [cell.textLabel.text isEqualToString:currentLeft]) ? TRUE : FALSE;
	if (usedName && (buttonIndex == 0 || buttonIndex == 2)) {
		//Trying to delete or rename a row that has a checkmark for either right or left side; prevent it
		NSString *title = NSLocalizedString(@"Name Error", @"Error message title");
		NSString *msg = NSLocalizedString(@"This name is currently being used by either the right or left side.\nYou can't rename or delete this row right now.\nSelect a different name first, then you try your action again.", @"Deleting the selected row is not allowed.");
		
		[TSMessage showNotificationInViewController:self
											  title:title
										   subtitle:msg
											  image:[UIImage imageNamed:@"alertButtonWhite"]
											   type:TSMessageNotificationTypeError
										   duration:TSMessageNotificationDurationAutomatic
										   callback:nil
										buttonTitle:NSLocalizedString(@"Dismiss", @"Dismiss button title.")
									 buttonCallback:nil
										 atPosition:TSMessageNotificationPositionTop
							   canBeDismissedByUser:YES];
		[cell setSlideState:SESlideTableViewCellSlideStateCenter animated:YES];
		
		return;
	}
	
	//Called when one of the cell buttons are tapped
	switch (buttonIndex) {
	  case 0:
			//Rename row
			[self addNewActionNameRow:cell.textLabel.text];
			break;
	  case 1:
			[self addNewActionNameRow:@""];
			break;
	  case 2:
			//Delete row, first check if the row being deleted is the currently selected row. Can't delete a row that's selected.
			if (cell == selectedCell) {
				//Trying to delete a row that has a checkmark, prevent it
				NSString *title = NSLocalizedString(@"Delete Error", @"Error message title");
				NSString *msg = NSLocalizedString(@"This is the currently selected row and it can't be deleted.\nTo delete this row, select a different row first then delete this row.", @"Deleting the selected row is not allowed.");
				
				[TSMessage showNotificationInViewController:self
													  title:title
												   subtitle:msg
													  image:[UIImage imageNamed:@"alertButtonWhite"]
													   type:TSMessageNotificationTypeError
												   duration:TSMessageNotificationDurationAutomatic
												   callback:nil
												buttonTitle:NSLocalizedString(@"Dismiss", @"Dismiss button title.")
											 buttonCallback:nil
												 atPosition:TSMessageNotificationPositionTop
									   canBeDismissedByUser:YES];
				
				return;
			}
			
			//If the row to be deleted is not the selected row, next check if it's the last row.
			//Deleting the last row is not allowed because then the user will not see the button to add a new row.
			if ([self.tableView numberOfRowsInSection:0] > 1) {
				[self.actionNamesList removeObjectAtIndex:path.row];
				rowCanSlide = YES;
				[self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView reloadData];
			} else {
				//Can't delete the last row, show dropdown message from top
				NSString *title = NSLocalizedString(@"Delete Error", @"Error message title");
				NSString *msg = NSLocalizedString(@"Deleting the last row is not allowed.\nYou can rename the row or add new rows.", @"Deleting the last row is not allowed.");
				[TSMessage showNotificationInViewController:self
													  title:title
												   subtitle:msg
													  image:[UIImage imageNamed:@"alertButtonWhite"]
													   type:TSMessageNotificationTypeError
												   duration:TSMessageNotificationDurationAutomatic
												   callback:nil
												buttonTitle:NSLocalizedString(@"Dismiss", @"Dismiss button title.")
											 buttonCallback:nil
												 atPosition:TSMessageNotificationPositionTop
									   canBeDismissedByUser:YES];
				[cell setSlideState:SESlideTableViewCellSlideStateCenter animated:YES];
			}
			break;
	  default:
			[cell setSlideState:SESlideTableViewCellSlideStateCenter animated:YES];
			break;
	}
}

-(void)slideTableViewCell:(SESlideTableViewCell *)cell willSlideToState:(SESlideTableViewCellSlideState)slideState {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if (indexPath) {
		if (slideState != SESlideTableViewCellSlideStateCenter) {
			if (m_currentIndexPath) {
				SESlideTableViewCell *cell = [self.tableView cellForRowAtIndexPath:m_currentIndexPath];
				[cell setSlideState:SESlideTableViewCellSlideStateCenter animated:YES];
			}
		}
		
	}
}

-(void)slideTableViewCell:(SESlideTableViewCell *)cell didSlideToState:(SESlideTableViewCellSlideState)slideState {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if (slideState != SESlideTableViewCellSlideStateCenter) {
		m_currentIndexPath = indexPath;
	}
}

-(BOOL)slideTableViewCell:(SESlideTableViewCell *)cell canSlideToState:(SESlideTableViewCellSlideState)slideState {
	return rowCanSlide;
}

#pragma mark - Add ActionName Row

 /*!
 *  @author Me, 10-29-15 16:10
 *
 *  Adds a new row and edits an existing row for Action Names.
 *  Depending on what it sent in actionNameText will determine if it's Add or Edit.
 *
 *  @param actionNameText String Will be nil for a new row and contain the existing
 *			ActionName for a rename.
 */
- (void)addNewActionNameRow:(NSString *)actionNameText {
	//Show message box to user and allow them to type in new name
	NSString *title;
	NSString *msg;
	if ([actionNameText isEqualToString:@""]) {
		//This was called by the 'New' cell button, so add a new row
		title = NSLocalizedString(@"New Action Name", @"Add new Action Name message box title");
		msg = NSLocalizedString(@"Enter the new Action Name", @"Enter the new Action Name message box");
		
	} else {
		//Called by 'rename' so change the existing row text
		title = NSLocalizedString(@"Rename Action Name", @"Add new Action Name message box title");
		msg = NSLocalizedString(@"Rename the existing Action Name", @"Enter the new Action Name message box");
	}
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
																   message:msg
															preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
											   handler:^(UIAlertAction * action) {
												   //Take the text the user entered and insert it into the array first, then into the tableview
												   NSString *text = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
												   if ([actionNameText isEqualToString:@""]) {
													   //Add new row
													   [self.actionNamesList insertObject:text atIndex:0];
													   NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
													   [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
													   
												   } else {
													   //Rename existing row
													   [self.actionNamesList replaceObjectAtIndex:m_currentIndexPath.row withObject:text];
													   SESlideTableViewCell *cell = [self.tableView cellForRowAtIndexPath:m_currentIndexPath];
													   cell.textLabel.text = text;
													   if ([cell slideState] != SESlideTableViewCellSlideStateCenter) {
														   rowCanSlide = YES;
														   [cell setSlideState:SESlideTableViewCellSlideStateCenter animated:YES];
													   }
													   
												   }
												   text = nil;
											   }];
	UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
												   handler:^(UIAlertAction * action) {
													   //User tapped Cancel, dismiss alert
													   [alert dismissViewControllerAnimated:YES completion:nil];
												   }];
	
	[alert addAction:ok];
	[alert addAction:cancel];
	//Get text from user
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
		
		textField.delegate = self;
		textField.placeholder = NSLocalizedString(@"Action Name (25 char. limit)", @"Action Name");
	}];
	[self presentViewController:alert animated:YES completion:^{
		SESlideTableViewCell *cell = [self.tableView cellForRowAtIndexPath:m_currentIndexPath];
		[cell setSlideState:SESlideTableViewCellSlideStateCenter animated:YES];
	}];
	

}

-(void)renameActionName:(SESlideTableViewCell *)cell {
	//Allows the user to rename an existing cell
	[self addNewActionNameRow:cell.textLabel.text];
}

#pragma mark - 3D Touch

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.actionNamesList count]; i++) {
        NSString *name = self.actionNamesList[i];
        UIPreviewAction *action = [UIPreviewAction actionWithTitle:name
                                                             style:UIPreviewActionStyleDefault
                                                           handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
                                                               switch (self.selectedActionRow) {
                                                                   case 1:
                                                                       //Left side
                                                                       [defaults setObject:name forKey:@"leftActionName"];
                                                                       break;
                                                                   case 2:
                                                                       //Right side
                                                                       [defaults setObject:name forKey:@"rightActionName"];
                                                                       break;
                                                                   default:
                                                                       break;
                                                               }
                                                               [defaults setInteger:self.selectedActionRow forKey:@"updatedActionNumber"];
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"updateActionNames" object:self];
                                                               });
                                                               id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                                               [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                                                                                     action:@"3D Touch"
                                                                                                                      label:name
                                                                                                                      value:nil] build]];
                                                               
                                                           }];
        [list addObject:action];
        }

    self.previewActions = [UIPreviewActionGroup actionGroupWithTitle:@"Group"
                                                               style:UIPreviewActionStyleDefault
                                                             actions:list];
    return list;
}

#pragma mark - UITextView Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	//Only allow 25 characters for Action Names
	if (textField.text.length < 25) {
		
		return YES;
	}
	
	//Allow deleting chars if max has been reached
	if (textField.text.length == 25 && string.length == 0) {
		return YES;
	}
	
	return NO;
}

#pragma mark - Segue Delegate

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
	return UIModalPresentationNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
