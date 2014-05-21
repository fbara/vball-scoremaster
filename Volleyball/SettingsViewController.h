//
//  SettingsViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/20/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource>


@property (weak, nonatomic) IBOutlet UIPickerView *opponentPicker;
@property (weak, nonatomic) IBOutlet UITextField *addNewOpponent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gamesControl;
@property (weak, nonatomic) IBOutlet UIButton *homeTeamColor;
@property (weak, nonatomic) IBOutlet UIButton *visitingTeamColor;

- (IBAction)homeTeamBackgroundColor:(id)sender;
- (IBAction)visitingTeamBackgroundColor:(id)sender;

- (IBAction)doneEditing:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)numberOfGamesSegment:(id)sender;

@end
