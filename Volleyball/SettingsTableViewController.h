//
//  SettingsTableViewController.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *homeTeamColor;
@property (weak, nonatomic) IBOutlet UIButton *visitingTeamColor;
@property (weak, nonatomic) IBOutlet UITextField *notificationName;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameOfPlayer;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *notificationLabels;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *notificationTextEntries;
@property (weak, nonatomic) IBOutlet UILabel *settingsSavedNotification;

- (IBAction)homeTeamBackgroundColor:(id)sender;
- (IBAction)visitingTeamBackgroundColor:(id)sender;

@end
