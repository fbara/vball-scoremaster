//
//  SupportTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 8/20/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SupportTableViewController.h"
#import "Chameleon.h"
#import "VTAcknowledgementsViewController.h"

static NSString* const kiTunesID = @"886670213";


//@interface SupportTableViewController ()
//
//@end

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
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
     
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.row) {
    case 0:
        //BaraLabs website
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://baralabs.github.io/vballscoremaster/"] options:@{} completionHandler:nil];
        break;
		case 1:
			//Launch Twitter to @BaraLabs page
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/baralabs"]];
			break;
    case 2:
      //Privacy policy
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://baralabs.github.io/vballscoremaster/privacypolicy/"]];
			break;
		case 3:
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
	
    return 4;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark - Acknowledgements

-(void)showAcknowledgements {
  //TODO: Not working, needs to be fixed.
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
