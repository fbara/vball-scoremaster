//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "VolleyBallViewController.h"
#import "DefaultScoreViewController.h"
#import "SettingsViewController.h"

//Constants for use when extending this to other sports
NSString *const EMBED_HOME = @"embedHome";
NSString *const EMBED_VISITOR = @"embedVisitor";
int const EMBED_MAX_GAMES = 3;


@interface VolleyBallViewController ()

@property (weak, atomic)UIPageViewController *homePageViewController;
@property (weak, atomic)UIPageViewController *visitorPageViewController;
@property (weak, nonatomic)UITextField *activeField;
@property (weak, nonatomic) IBOutlet UILabel *gameLabel;
@property (weak, nonatomic) IBOutlet UILabel *spikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *aceLabel;
@property (weak, nonatomic) IBOutlet UILabel *servingLabel;



@end

@implementation VolleyBallViewController


#pragma mark - Initialize Screen

//Called first, before the main view controller is loaded
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:EMBED_HOME]) {
        self.homePageViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:EMBED_VISITOR]) {
        self.visitorPageViewController = segue.destinationViewController;
    }
    
}

//Called second, after the segue's are setup
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initializeHomeScore];
    [self initializeVisitorScore];
    [self resetGameKillAce];
    self.visitingTeamName.delegate = self;
    self.homeTeamName.delegate = self;

    
    _homeSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    _homeSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;

    _visitingSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    _visitingSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;

    [_homeTeamContainer addGestureRecognizer:_homeSwipeGesture];
    [_vistingTeamContainer addGestureRecognizer:_visitingSwipeGesture];
    
    
}


- (void)initializeHomeScore
{
    self.homeColor = [self colorHomeScoreView];
    DefaultScoreViewController *homeScoreViewController = [self createViewControllersForScore:0
                                                                             withColor:self.homeColor];
    self.homePageViewController.dataSource = self;
    [self.homePageViewController setViewControllers:@[homeScoreViewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];

    
}

- (void)initializeVisitorScore
{
    self.visitorColor = [self colorVisitorScoreView];
    DefaultScoreViewController *visitorScoreViewController = [self createViewControllersForScore:0
                                                                                withColor:self.visitorColor];
    self.visitorPageViewController.dataSource = self;
    [self.visitorPageViewController setViewControllers:@[visitorScoreViewController]
                                             direction:UIPageViewControllerNavigationDirectionForward
                                              animated:YES
                                            completion:nil];
    
}

- (DefaultScoreViewController *)createViewControllersForScore:(int)score withColor:(UIColor *)color
{
    //Create a new scoreViewController and initialize it with 'nil',
    //that will create one with a xib of the same name
    DefaultScoreViewController *newScoreViewController = [[DefaultScoreViewController alloc]
                                                   initWithNibName:nil
                                                   bundle:nil];
    //Set the properties of the score view
    newScoreViewController.view.backgroundColor = color;
    newScoreViewController.score = score;
    
    return newScoreViewController;
}

- (void)moveScoreView:(id)sender
{
    NSLog(@"Moving: %@", sender);
}

- (UIColor *)colorHomeScoreView
{
    //Get home team background colors
    UIColor *colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theHomeData = [[NSUserDefaults standardUserDefaults] dataForKey:@"homeTeamColor"];
    if (theHomeData != nil) {
        colorHome = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theHomeData];
    } else {
        colorHome = [UIColor blueColor];
    }
    return colorHome;
}

- (UIColor *)colorVisitorScoreView
{
    //Get visiting team background colors
    UIColor *colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theVisitorData = [[NSUserDefaults standardUserDefaults] dataForKey:@"visitorTeamColor"];
    if (theVisitorData != nil) {
        colorVisitor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theVisitorData];
    } else {
        colorVisitor = [UIColor orangeColor];
    }
    return colorVisitor;
}

- (void)resetGameKillAce
{
    //Resets Game, Kill, and Ace to 0
    self.gameNumber.text = @"1";
    self.killNumber.text = @"0";
    self.aceNumber.text = @"0";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.homePageViewController.view.backgroundColor = [self colorHomeScoreView];
    self.visitorPageViewController.view.backgroundColor = [self colorVisitorScoreView];
    
}

#pragma mark - UIPanGestureRecognizers

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
//    if (UIGestureRecognizerStateBegan == recognizer.state) {
//
//        
    NSLog(@"handleSwipe:");
    //Get the center of each score view container
    CGPoint targetHomeCenter = _vistingTeamContainer.center;
    CGPoint targetVisitorCenter = _homeTeamContainer.center;
    CGPoint targetHomeNameCenter = _visitingTeamName.center;
    CGPoint targetVisitorNameCenter = _homeTeamName.center;
    
    
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.5f
              initialSpringVelocity:1.0f
                            options:0
                         animations:^(){
                             [self hideUI:YES];
                             _homeTeamContainer.center = targetHomeCenter;
                             _homeTeamName.center = targetHomeNameCenter;
                             _vistingTeamContainer.center = targetVisitorCenter;
                             _visitingTeamName.center = targetVisitorNameCenter;
                             [self hideUI:NO];
                         }
                         completion:nil];
//    }

    _homeSwipeGesture.direction = (_homeSwipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) ? UISwipeGestureRecognizerDirectionRight : UISwipeGestureRecognizerDirectionLeft;
    _visitingSwipeGesture.direction = (_visitingSwipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) ? UISwipeGestureRecognizerDirectionRight : UISwipeGestureRecognizerDirectionLeft;
    
}

- (void)hideUI:(BOOL)hide
{
    self.gameNumber.hidden = hide;
    self.killNumber.hidden = hide;
    self.aceNumber.hidden = hide;
    self.teamServingArrow.hidden = hide;
    self.gameLabel.hidden = hide;
    self.aceLabel.hidden = hide;
    self.spikeLabel.hidden = hide;
    self.servingLabel.hidden = hide;
}

#pragma mark - Button Presses
/*!
 *  What happens when 'Game' is pressed
 */
- (IBAction)gamePressed
{
    //Grab the game number and add 1 but shouldn't be more than 3
    int lableNum = [self.gameNumber.text intValue];
    
    if (!(lableNum == EMBED_MAX_GAMES)) {
        lableNum = lableNum + 1;
        self.gameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
        
        //Reset the scores to start a new game
        [self initializeHomeScore];
        [self initializeVisitorScore];
    } else {
        //Reached the maximum number of games for this sport
        NSString *maxGameLimit = [NSString stringWithFormat:@"The maximum number of games for this sport is %d", EMBED_MAX_GAMES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Max game limit reached"
                                                        message:maxGameLimit
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}

- (IBAction)killsPressed
{
    int lableNum = [self.killNumber.text intValue];
    lableNum = lableNum + 1;
    self.killNumber.text = [NSString stringWithFormat:@"%d", lableNum];
    
//    [self sendSMS:@"Kill's" action:lableNum];
    
//    //Send the SMS message
//    MFMessageComposeViewController *textComposer = [[MFMessageComposeViewController alloc] init];
//    [textComposer setMessageComposeDelegate:self];
//    
//    if ([MFMessageComposeViewController canSendText]) {
//        NSString *killNum = [NSString stringWithFormat:@"Shane has %d kills!", lableNum];
//        [textComposer setRecipients:[NSArray arrayWithObjects:@"6305449503", nil]];
//        
//        [textComposer setBody:killNum];
//        [self presentViewController:textComposer
//                           animated:YES
//                         completion:nil];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to send message"
//                                                        message:nil
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil];
//        [alert show];
//
//    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)swap:(id)sender
{
    CGPoint targetHomeCenter = _vistingTeamContainer.center;
    CGPoint targetVisitorCenter = _homeTeamContainer.center;
    CGPoint targetHomeNameCenter = _visitingTeamName.center;
    CGPoint targetVisitorNameCenter = _homeTeamName.center;
    
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:1.0f
                        options:0
                     animations:^(){
                         [self hideUI:YES];
                         _homeTeamContainer.center = targetHomeCenter;
                         _homeTeamName.center = targetHomeNameCenter;
                         _vistingTeamContainer.center = targetVisitorCenter;
                         _visitingTeamName.center = targetVisitorNameCenter;
                         [self hideUI:NO];
                     }
                     completion:nil];
}

- (IBAction)teamServingDirection
{
    
}

- (IBAction)acePressed
{
    int lableNum = [self.aceNumber.text intValue];
    lableNum = lableNum + 1;
    self.aceNumber.text = [NSString stringWithFormat:@"%d", lableNum];
}

- (IBAction)newMatch
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Game?"
                                                        message:@"Reset scores, ace's, and kill's and start a new match?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [self initializeHomeScore];
        [self initializeVisitorScore];
        [self resetGameKillAce];
    }
}

- (void)sendSMS:(NSString *)name action:(int)number
{
    //Send the SMS message
    MFMessageComposeViewController *textComposer = [[MFMessageComposeViewController alloc] init];
    [textComposer setMessageComposeDelegate:self];
    
    if ([MFMessageComposeViewController canSendText]) {
        //NSString *killNum = [NSString stringWithFormat:@"Shane has %d kills!", lableNum];
        [textComposer setRecipients:[NSArray arrayWithObjects:@"6305449503", nil]];
        NSString *message = [NSString stringWithFormat:@"Shane has %d %@!", number, name];

        [textComposer setBody:message];
        [self presentViewController:textComposer
                           animated:YES
                         completion:nil];
        
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    //Cast the viewController as a ScoreViewController so we can act on its properties
    DefaultScoreViewController *oldViewController = (DefaultScoreViewController *)viewController;
    
    //Check the score, if it's more than 99, don't let the number get any higher
    if (oldViewController.score == 99) {
        return nil;
    }
    
    //Setup the new view controller with the new, higher score
    DefaultScoreViewController *newViewController = [self createViewControllersForScore:0
                                                                       withColor:[UIColor clearColor]];
    newViewController.score = oldViewController.score + 1;
    
    //Check to see which view controller we're updating so the background color can be set correctly
    if (pageViewController == _homePageViewController) {
        //Home team score changing
        newViewController.view.backgroundColor = self.homeColor;
    } else {
        //Visitor team score changing
        newViewController.view.backgroundColor = self.visitorColor;
    }
    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    //Cast the viewController as a ScoreViewController so we can act on its properties
    DefaultScoreViewController *oldViewController = (DefaultScoreViewController *)viewController;
    
    //Check the score, if it's 0, don't let the number get any lower
    if (oldViewController.score == 0) {
        return nil;
    }
    
    //Setup the new view controller with the new, higher score
    DefaultScoreViewController *newViewController = [self createViewControllersForScore:0
                                                                              withColor:self.visitorColor];
    
    newViewController.score = oldViewController.score - 1;
    
    //Check to see which view controller we're updating so the background color can be set correctly
    if (pageViewController == _homePageViewController) {
        //Home team score changing
        newViewController.view.backgroundColor = self.homeColor;
        
    } else {
        //Visitor team score changing
        newViewController.view.backgroundColor = self.visitorColor;
    }
                                                     
    
    return newViewController;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
    [textField resignFirstResponder];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
