//
//  SettingsViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/20/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIButton *homeTeamColor;
@property (weak, nonatomic) IBOutlet UIButton *visitingTeamColor;

- (IBAction)homeTeamBackgroundColor:(id)sender;
- (IBAction)visitingTeamBackgroundColor:(id)sender;

- (IBAction)saveSettings:(id)sender;

@end
