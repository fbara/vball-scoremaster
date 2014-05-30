//
//  VolleyBallViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface VolleyBallViewController : UIViewController <UIPageViewControllerDataSource,UIAlertViewDelegate,UITextFieldDelegate, MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate>

@property UIColor *homeColor;
@property UIColor *visitorColor;
@property (weak, nonatomic) IBOutlet UILabel *gameNumber;
@property (weak, nonatomic) IBOutlet UILabel *killNumber;
@property (weak, nonatomic) IBOutlet UILabel *aceNumber;
@property (weak, nonatomic) IBOutlet UITextField *visitingTeamName;
@property (weak, nonatomic) IBOutlet UITextField *homeTeamName;
@property (weak, nonatomic) IBOutlet UIImageView *serveDirectionArrow;

@property (weak, nonatomic) IBOutlet UIView *homeTeamContainer;
@property (weak, nonatomic) IBOutlet UIView *vistingTeamContainer;
@property UISwipeGestureRecognizer *homeSwipeGesture;
@property UISwipeGestureRecognizer *visitingSwipeGesture;
- (IBAction)teamServingArrowDirection:(id)sender;

- (IBAction)teamServingDirection;
- (IBAction)gamePressed;
- (IBAction)killsPressed;
- (IBAction)acePressed;
- (IBAction)newMatch;
@end
