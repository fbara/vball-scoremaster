//
//  VolleyBallViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GAITrackedViewController.h"


@interface VolleyBallViewController : GAITrackedViewController <UIPageViewControllerDataSource,UIAlertViewDelegate,UITextFieldDelegate, MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate,UIPageViewControllerDelegate>

@property UIColor *homeColor;
@property UIColor *visitorColor;

@property (weak, nonatomic) IBOutlet UILabel *gameNumber;
@property (weak, nonatomic) IBOutlet UILabel *secondActionName;
@property (weak, nonatomic) IBOutlet UILabel *firstActionName;
@property (weak, nonatomic) IBOutlet UITextField *visitingTeamName;
@property (weak, nonatomic) IBOutlet UITextField *homeTeamName;
@property (weak, nonatomic) IBOutlet UILabel *leftActionLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightActionLabel;
@property (weak, nonatomic) IBOutlet UIView *homeTeamContainer;
@property (weak, nonatomic) IBOutlet UIView *vistingTeamContainer;
@property (weak, nonatomic) IBOutlet UILabel *homeGame1;
@property (weak, nonatomic) IBOutlet UILabel *homeGame2;
@property (weak, nonatomic) IBOutlet UILabel *homeGame3;
@property (weak, nonatomic) IBOutlet UILabel *visitGame1;
@property (weak, nonatomic) IBOutlet UILabel *visitGame2;
@property (weak, nonatomic) IBOutlet UILabel *visitGame3;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageImage;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *pastScoreCollection;
@property (weak, nonatomic) IBOutlet UILabel *rightActionNameNumber;
@property (weak, nonatomic) IBOutlet UILabel *leftActionNameNumber;
@property (weak, nonatomic) IBOutlet UIButton *mainPageTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *mainPageFacebookButton;


@property UISwipeGestureRecognizer *homeSwipeGesture;
@property UISwipeGestureRecognizer *visitingSwipeGesture;


- (IBAction)leftActionLongPress:(UILongPressGestureRecognizer *)recognizer;
- (IBAction)rightActionLongPress:(UILongPressGestureRecognizer *)recognizer;

- (IBAction)gamePressed:(UIButton *)sender;
- (IBAction)rightActionPressed:(UIButton *)sender;
- (IBAction)leftActionPressed:(UIButton *)sender;
- (IBAction)newMatch:(UIBarButtonItem *)sender;
- (IBAction)sendInstantMessage:(UIButton *)sender;
@end
