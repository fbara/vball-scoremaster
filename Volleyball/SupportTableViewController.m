//
//  SupportTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 8/20/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SupportTableViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <AppbotX/ABX.h>
#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>

static NSString* const kiTunesID = @"886670213";


@interface SupportTableViewController ()

@property (strong, nonatomic) ABXPromptView *promptView;

@end

@implementation SupportTableViewController

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
    self.title = NSLocalizedString(@"Support", @"Title for Support view.");
	
	self.tableView.backgroundColor = FlatBlackDark;
	self.tableView.sectionIndexBackgroundColor = FlatBlackDark;
	
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    //Show alert to user the first time they enter the Support screen and there's
    //an active alert.
    [ABXNotification fetchActive:^(NSArray *notifications, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        if (responseCode == ABXResponseCodeSuccess) {
            if (notifications.count > 0) {
                ABXNotification *notification = [notifications firstObject];
                
                if (![notification hasSeen]) {
                    //Show the view
                    [ABXNotificationView show:notification.message
                                   actionText:notification.actionLabel
                              backgroundColor:FlatBlueDark
                                    textColor:[UIColor whiteColor]
                                  buttonColor:[UIColor redColor]
                                 inController:self
                                  actionBlock:^(ABXNotificationView *view) {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:notification.actionUrl]];
                                  } dismissBlock:^(ABXNotificationView *view) {
                                      //Mark alert as being seen so it's not shown again
                                      [notification markAsSeen];
                                      }];
                    return;
                }
            }
        }
        
    }];
     
}

#pragma mark - Appbotx methods

- (void)appbotPromptClose
{
    self.promptView.hidden = YES;
}

- (void)appbotPromptForFeedback
{
    if ([self canSendAnalytics]) {
        [self logShortcutUsed:@"Appbot Settings Feedback"];
    }
    [ABXFeedbackViewController showFromController:self placeholder:nil];
    self.promptView.hidden = YES;
}

- (void)appbotPromptForReview
{
    if ([self canSendAnalytics]) {
        [self logShortcutUsed:@"Appbot Settings Review"];
    }
    [ABXAppStore openAppStoreReviewForApp:kiTunesID];
    self.promptView.hidden = YES;
 
}

#pragma mark - Analytics

- (BOOL)canSendAnalytics {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *analytics = [defaults stringForKey:@"analyticsChoice"];
    if ([analytics isEqualToString:@"Opt in"]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)logShortcutUsed:(NSString *)shortcut
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"shortcut"
                                                           label:shortcut
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.row) {
		case 0:
			//Link to First Draw
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://geni.us/first"]];
			break;
		case 1:
            //Show version info
            [ABXVersionsViewController showFromController:self];
            break;
        case 2:
            //Show FAQ
            //Access AppbotX FAQ's
            [ABXFAQsViewController showFromController:self
                                    hideContactButton:NO
                                      contactMetaData:nil
                                        initialSearch:nil];
            break;
        case 3:
            //Show Feedback form
            //Access AppbotX feedback form
            [ABXFeedbackViewController showFromController:self
                                              placeholder:@"Message to the Developer"
                                                    email:@"Enter your email address"
                                                 metaData:nil
                                                    image:nil];
            break;
        case 4:
            //Notifications
            [ABXNotificationsViewController showFromController:self];
            break;
        case 5:
            //iTunes review
            [ABXAppStore openAppStoreReviewForApp:kiTunesID];
            break;
        case 6:
            //BaraLabs website
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://baralabs.com"]];
            break;
		case 7:
			//Launch Twitter to @BaraLabs page
			//Check if Twitter app is installed. If it is, launch it. If not, open Safari to BaraLabs.
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=baralabs"]]) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=baralabs"]];
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/baralabs"]];
			}
			break;
        case 8:
            //Privacy policy
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://baralabs.com/privacy-policy.html"]];
			break;
		case 9:
			//Show acknowledgements
			[self showAcknowledgements];
			break;
        default:
            break;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	
    return 10;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	//Add row color
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	//cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	if (indexPath.row == 0) {
		[self setCellColor:FlatYellowDark ForCell:cell TextColor:FlatBlack];
	} else {
		[self setCellColor:[UIColor blackColor] ForCell:cell TextColor:FlatRedDark];
	}

}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	//Reset color
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	if (indexPath.row == 0) {
		[self setCellColor:FlatYellow ForCell:cell TextColor:FlatRedDark];
	} else {
		[self setCellColor:FlatBlackDark ForCell:cell TextColor:FlatWhite];
	}
}



-(void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell TextColor:(UIColor *)textColor {
	cell.contentView.backgroundColor = color;
	cell.backgroundColor = color;
	cell.textLabel.textColor = textColor;
	cell.textLabel.backgroundColor = [UIColor clearColor];
	
}

#pragma mark - Acknowledgements

-(void)showAcknowledgements {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Pods-VBall ScoreMaster-acknowledgements" ofType:@"plist"];
	VTAcknowledgementsViewController *ackVC = [[VTAcknowledgementsViewController alloc] initWithAcknowledgementsPlistPath:path];
	ackVC.headerText = NSLocalizedString(@"VBall ScoreMaster was created with the help of the following:", @"VBall ScoreMaster was created with the help of the following:");
	[self.navigationController pushViewController:ackVC animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
