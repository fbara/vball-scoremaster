//
//  SettingsTableViewController.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface SettingsTableViewController : UITableViewController <UITableViewDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editSettingsButton;
@property (weak, nonatomic) IBOutlet UIButton *homeTeamColor;
@property (weak, nonatomic) IBOutlet UIButton *visitingTeamColor;
@property (weak, nonatomic) IBOutlet UITextField *notificationName;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameOfPlayer;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *settingsLabels;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *notificationTextEntries;
@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray *settingsButtons;
@property (weak, nonatomic) IBOutlet UILabel *settingsSavedNotification;
@property (weak, nonatomic) IBOutlet UIButton *addPhoneNumberButton;
@property (weak, nonatomic) IBOutlet UILabel *firstActionNameSelected;
@property (weak, nonatomic) IBOutlet UILabel *secondActionNameSelected;

- (IBAction)homeTeamBackgroundColor:(id)sender;
- (IBAction)visitingTeamBackgroundColor:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)getPhoneNumberFromAddressBook:(id)sender;

@end
