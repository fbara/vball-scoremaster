//
//  VolleyBallViewController.h
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <GoogleAnalytics/GAITrackedViewController.h>
#import <AppbotX/ABXPromptView.h>
#import <Social/Social.h>
@import QuartzCore;

@interface VolleyBallViewController : GAITrackedViewController <UIPageViewControllerDataSource, UIAlertViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate, UIPageViewControllerDelegate, ABXPromptViewDelegate>

@property UIColor* homeColor;
@property UIColor* visitorColor;

@property (weak, nonatomic) IBOutlet UILabel* gameNumber;
@property (weak, nonatomic) IBOutlet UILabel* secondActionName;
@property (weak, nonatomic) IBOutlet UILabel* firstActionName;
@property (weak, nonatomic) IBOutlet UITextField* visitingTeamName;
@property (weak, nonatomic) IBOutlet UITextField* homeTeamName;
@property (weak, nonatomic) IBOutlet UILabel* leftActionLabel;
@property (weak, nonatomic) IBOutlet UILabel* rightActionLabel;
@property (weak, nonatomic) IBOutlet UIView* homeTeamContainer;
@property (weak, nonatomic) IBOutlet UIView* vistingTeamContainer;

@property (weak, nonatomic) IBOutlet UILabel* homeGame1;
@property (weak, nonatomic) IBOutlet UILabel* homeGame2;
@property (weak, nonatomic) IBOutlet UILabel* homeGame3;
@property (weak, nonatomic) IBOutlet UILabel* homeGame4;
@property (weak, nonatomic) IBOutlet UILabel* visitGame1;
@property (weak, nonatomic) IBOutlet UILabel* visitGame2;
@property (weak, nonatomic) IBOutlet UILabel* visitGame3;
@property (weak, nonatomic) IBOutlet UILabel* visitGame4;

@property (weak, nonatomic) IBOutlet UIButton* sendMessageImage;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* pastScoreCollection;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* pastHomeScoreCollection;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* pastVisitorScoreCollection;
@property (weak, nonatomic) IBOutlet UILabel* rightActionNameNumber;
@property (weak, nonatomic) IBOutlet UILabel* leftActionNameNumber;

@property (weak, nonatomic) IBOutlet UIButton* mainPageTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton* mainPageFacebookButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *matchButton;

@property UISwipeGestureRecognizer* homeSwipeGesture;
@property UISwipeGestureRecognizer* visitingSwipeGesture;

- (IBAction)goToSettings:(UIBarButtonItem*)sender;
- (IBAction)leftActionLongPress:(UILongPressGestureRecognizer*)recognizer;
- (IBAction)rightActionLongPress:(UILongPressGestureRecognizer*)recognizer;

- (IBAction)gamePressed:(UIButton*)sender;
- (IBAction)rightActionPressed:(UIButton*)sender;
- (IBAction)leftActionPressed:(UIButton*)sender;
- (IBAction)newMatch:(UIButton *)sender;
- (UIImage *)getScreenImage;
- (IBAction)sendInstantMessage:(UIButton*)sender;

- (void)startNewMatch;
- (void)gamePressedFromShortcut;
- (void)logShortcutUsed:(NSString *)shortcut;
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController;

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController;

- (void)messageComposeViewController:(nonnull MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;

- (void)appbotPromptClose;

- (void)appbotPromptForFeedback;

- (void)appbotPromptForReview;

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder;

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection;

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container;

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize;

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container;

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator;

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator;

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator;

- (void)setNeedsFocusUpdate;

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context;

- (void)updateFocusIfNeeded;

@end
