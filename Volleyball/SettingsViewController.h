//
//  SettingsViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/20/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate>
{
    IBOutlet UIScrollView *settingsScrollView;
}


@property (weak, nonatomic) IBOutlet UIButton *homeTeamColor;
@property (weak, nonatomic) IBOutlet UIButton *visitingTeamColor;
@property (weak, nonatomic) IBOutlet UITextField *notificationName;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameOfPlayer;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *notificationLabels;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *notificationTextEntries;
@property (weak, nonatomic) IBOutlet UILabel *settingsSavedNotification;

- (IBAction)dismissKeyboard:(id)sender;
//- (void)dismissKeyboard;
- (IBAction)homeTeamBackgroundColor:(id)sender;
- (IBAction)visitingTeamBackgroundColor:(id)sender;
- (IBAction)notificationControl:(id)sender;
- (IBAction)saveSettings;

@end
