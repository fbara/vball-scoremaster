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

@interface ActionLabelTableViewController () <UITextFieldDelegate, TSMessageViewProtocol> {
	//NSMutableArray *actionNamesList;
	BOOL firstTimeShown;
	BOOL rowCanSlide;
	NSUserDefaults *defaults;
	NSIndexPath *m_currentIndexPath;
}
@property (strong, nonatomic)NSMutableArray *actionNamesList;

@end
@implementation ActionLabelTableViewController

-(NSMutableArray *)actionNamesList {
	//Create array of ActionNames
	if (!_actionNamesList) {
		//Names don't exist yet, create them from standard defaults
		defaults = [NSUserDefaults standardUserDefaults];
		_actionNamesList = [[NSMutableArray alloc] init];
		_actionNamesList = [[defaults objectForKey:@"ActionNames"] mutableCopy];
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
	
	//Load default ActionNames if array doesn't yet exist
	if (!self.actionNamesList) {
		self.actionNamesList = [[NSMutableArray alloc] initWithObjects:@"Spike", @"Dig", @"Ace", @"Block", @"Set", @"Pass", nil];
	}
	//Add long press gesture for moving rows
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
																							action:@selector(longPressGesture:)];
	[self.tableView addGestureRecognizer:longPress];
	
    // Indicate this is the first time this view is seen
    firstTimeShown = YES;
	rowCanSlide = YES;
	[TSMessage setDelegate:self];
	
	//Setup bar buttons
	UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		  target:self
																		 action:@selector(addNewActionNameRow:)];
//TODO: Figure out how to have the tableview properly reload the data
	//Until that time, hide the 'reset' button
//	UIBarButtonItem *reset = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
//																		  target:self
//																		  action:@selector(resetActionNames:)];
//	
//	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
//								   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//								   target:self
//								   action:nil];
//	
//	fixedSpace.width = 20.0f;
	self.navigationItem.rightBarButtonItem = add;
	//self.navigationItem.rightBarButtonItem = add;

}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Setup Google Analytics tracker for this screen
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker set:kGAIScreenName value:@"Action Names"];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewWillDisappear:(BOOL)animated {
	
	//Save the Action Names
	[defaults setObject:self.actionNamesList forKey:@"ActionNames"];
	
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    defaults = [NSUserDefaults standardUserDefaults];
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

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.actionNamesList count];
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSIndexPath* oldIndex = [self.tableView indexPathForSelectedRow];
	[self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
	[self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
	[self.tableView cellForRowAtIndexPath:indexPath].highlighted = NO;
	
	return indexPath;
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
		[cell addRightButtonWithText:NSLocalizedString(@"Delete", @"Delete Action Name table row")
						   textColor:FlatWhite
					 backgroundColor:FlatRed];
		
		
		cell.textLabel.text = [self.actionNamesList objectAtIndex:indexPath.row];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	

    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
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
			// Prepare to call the delegate with the selected row name
			self.selectedActionName = cell.textLabel.text;
			[self.delegate actionNameSelected:self.selectedActionName];
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

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    // Set the header of the table with instructions to save changes
    UILabel* sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull];
    sectionHeader.backgroundColor = [UIColor clearColor];
	sectionHeader.font = [UIFont systemFontOfSize:14];
    sectionHeader.textColor = [UIColor darkGrayColor];
    if (IS_IPAD()) {
		sectionHeader.text = NSLocalizedString(@"   SELECT AN ACTION NAME", @"Tap on the Action Name for your player");
    } //else {
//        sectionHeader.text = NSLocalizedString(@"   SELECT AN ACTION NAME THEN TAP 'SAVE'", @"Tap on the Action Name for your player, then tap Save");
//    }
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
	[self presentViewController:alert animated:YES completion:^{
		[self.view setNeedsDisplay];
	}];
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

-(void)slideTableViewCell:(SESlideTableViewCell *)cell didTriggerRightButton:(NSInteger)buttonIndex {

	NSIndexPath *path = [self.tableView indexPathForCell:cell];
	//Called when one of the cell buttons are tapped
	switch (buttonIndex) {
	  case 0:
			//Rename row
			[self addNewActionNameRow:cell.textLabel.text];
			//[self renameActionName:cell];
			break;
	  case 1:
			//Delete row
			//Do not allow deleting last row
			if ([self.tableView numberOfRowsInSection:0] > 1) {
				[self.actionNamesList removeObjectAtIndex:path.row];
				rowCanSlide = YES;
				[self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView reloadData];
			} else {
				//Show message
				[TSMessage showNotificationWithTitle:@"Title" subtitle:@"Subtitle" type:TSMessageNotificationTypeError];
			}
			
			break;
	  default:
			break;
	}
	
	//Close the open cell
	//[cell animateToSlideState:SESlideTableViewCellSlideStateCenter velocity:0];
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
	
//	if (slideState == SESlideTableViewCellSlideStateRight) {
//		rowCanSlide = NO;
//	} else {
//		rowCanSlide = YES;
//	}
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
	if ([actionNameText isKindOfClass:[UIBarButtonItem class]]) {
		//This was called by the '+' bar button so add a new row
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
												   if ([actionNameText isKindOfClass:[UIBarButtonItem class]]) {
													   //Add new row
													   [self.actionNamesList insertObject:text atIndex:0];
													   NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
													   [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
													   
												   } else {
													   //Rename existing row
													   //NSString *oldName = [self.actionNamesList objectAtIndex:m_currentIndexPath.row];
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

#pragma mark - TSMessage Delegate
-(void)customizeMessageView:(TSMessageView *)messageView {
	messageView.alpha = 0.9;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
