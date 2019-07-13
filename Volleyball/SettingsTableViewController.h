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
#import "ActionLabelTableViewController.h"
@import StoreKit;
#import "VolleyBallIAPHelper.h"
#import "FCColorPickerViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface SettingsTableViewController
    : UITableViewController <UITableViewDelegate, /*ABPeoplePickerNavigationControllerDelegate,*/ CNContactPickerDelegate, CNContactViewControllerDelegate,
                             UITextViewDelegate, UITextFieldDelegate, ActionNameDelegate,
                             SKProductsRequestDelegate, SKPaymentTransactionObserver,FCColorPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton* homeTeamColor;
@property (weak, nonatomic) IBOutlet UIButton* visitingTeamColor;
@property (weak, nonatomic) IBOutlet UITextField* notificationName;
@property (weak, nonatomic) IBOutlet UISegmentedControl* sendNotificationSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *notificationTypeSwitch;
@property (weak, nonatomic) IBOutlet UITextField* nameOfPlayer;
@property (strong, nonatomic) IBOutletCollection(UILabel)
    NSArray* settingsLabels;
@property (weak, nonatomic) IBOutletCollection(UIButton)
    NSArray* settingsButtons;
@property (weak, nonatomic) IBOutlet UIButton* addPhoneNumberButton;
@property (strong, nonatomic) IBOutlet UILabel* leftActionNameSelected;
@property (strong, nonatomic) IBOutlet UILabel* rightActionNameSelected;
//@property (weak, nonatomic) IBOutlet UISegmentedControl* analyticsSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl* colorSettings;
@property (weak, nonatomic) IBOutlet UIButton *reviewButton;

//@property (weak, nonatomic) IBOutlet UISegmentedControl* twitterSwitch;
//@property (weak, nonatomic) IBOutlet UISegmentedControl* facebookSwitch;

- (IBAction)homeTeamBackgroundColor:(id)sender;
- (IBAction)visitingTeamBackgroundColor:(id)sender;
- (IBAction)getPhoneNumberFromAddressBook:(id)sender;
- (IBAction)notificationSwitch:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
//- (IBAction)sendAnalytics:(UISegmentedControl*)sender;
- (IBAction)colorSettings:(UISegmentedControl*)sender;
- (IBAction)notificationTypeSwitch:(UISegmentedControl *)sender;
//- (IBAction)sendWithFacebook:(UISegmentedControl*)sender;
//- (IBAction)sendWithTwitter:(UISegmentedControl*)sender;
- (IBAction)leaveReview:(UIButton *)sender;

@end
