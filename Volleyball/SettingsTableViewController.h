//
//  SettingsTableViewController.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/26/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "PhoneNumberFormatter.h"
#import "WEPopoverController.h"
#import "ColorViewController.h"

@interface SettingsTableViewController : UITableViewController <UITableViewDelegate,ABPeoplePickerNavigationControllerDelegate,UITextViewDelegate,UITextFieldDelegate,WEPopoverControllerDelegate,ColorViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *homeTeamColor;
@property (weak, nonatomic) IBOutlet UIButton *visitingTeamColor;
@property (weak, nonatomic) IBOutlet UITextField *notificationName;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sendNotificationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameOfPlayer;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *settingsLabels;
@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray *settingsButtons;
@property (weak, nonatomic) IBOutlet UIButton *addPhoneNumberButton;
@property (strong, nonatomic) IBOutlet UILabel *leftActionNameSelected;
@property (strong, nonatomic) IBOutlet UILabel *rightActionNameSelected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *analyticsSwitch;
@property (strong, nonatomic)WEPopoverController *colorPicker;

- (IBAction)homeTeamBackgroundColor:(id)sender;
- (IBAction)visitingTeamBackgroundColor:(id)sender;
- (IBAction)getPhoneNumberFromAddressBook:(id)sender;
- (IBAction)notificationSwitch:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)sendAnalytics:(UISegmentedControl *)sender;

@end
