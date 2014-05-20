//
//  VolleyBallViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>

@interface VolleyBallViewController : UIViewController <UIPageViewControllerDataSource,UIAlertViewDelegate,UITextFieldDelegate, MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate,ADBannerViewDelegate>

@property UIColor *homeColor;
@property UIColor *visitorColor;
@property (weak, nonatomic) IBOutlet UILabel *gameNumber;
@property (weak, nonatomic) IBOutlet UILabel *killNumber;
@property (weak, nonatomic) IBOutlet UILabel *aceNumber;
@property (weak, nonatomic) IBOutlet UITextField *otherTeamName;

- (IBAction)gamePressed;
- (IBAction)killsPressed;
- (IBAction)acePressed;

- (IBAction)newMatch;
@end
