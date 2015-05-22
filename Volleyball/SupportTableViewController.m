//
//  SupportTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 8/20/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SupportTableViewController.h"

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
    self.title = @"Support";
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    self.promptView.hidden = YES;
}

- (void)appbotPromptForReview
{
    [ABXAppStore openAppStoreReviewForApp:kiTunesID];
    self.promptView.hidden = YES;
    

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            //Show version info
            [ABXVersionsViewController showFromController:self];
            break;
        case 1:
            //Show FAQ
            //Access AppbotX FAQ's
            [ABXFAQsViewController showFromController:self
                                    hideContactButton:NO
                                      contactMetaData:nil
                                        initialSearch:nil];
            break;
        case 2:
            //Show Feedback form
            //Access AppbotX feedback form
            [ABXFeedbackViewController showFromController:self
                                              placeholder:@"Message to the Developer"
                                                    email:@"Enter your email address"
                                                 metaData:nil
                                                    image:nil];
            break;
        case 3:
            //Notifications
            [ABXNotificationsViewController showFromController:self];
            break;
        case 4:
            //iTunes review
            [ABXAppStore openAppStoreReviewForApp:kiTunesID];
            break;
        case 5:
            //BaraLabs website
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://baralabs.com"]];
            break;
		case 6:
			//Launch Twitter to @BaraLabs page
			//Check if Twitter app is installed. If it is, launch it. If not, open Safari to BaraLabs.
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=baralabs"]]) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=baralabs"]];
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/baralabs"]];
			}
			break;
        case 7:
            //Privacy policy
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://baralabs.com/privacy-policy.html"]];
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
	
    return 8;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
