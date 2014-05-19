//
//  VolleyBallViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/4/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "VolleyBallViewController.h"
#import "DefaultScoreViewController.h"

//Constants for use when extending this to other sports
NSString *const EMBED_HOME = @"embedHome";
NSString *const EMBED_VISITOR = @"embedVisitor";
NSString *const EMBED_GAME_NUMBER = @"1";
NSString *const EMBED_KILL_NUMBER = @"0";
NSString *const EMBED_ACE_NUMBER = @"0";


@interface VolleyBallViewController ()

@property (weak, atomic)UIPageViewController *homePageViewController;
@property (weak, atomic)UIPageViewController *visitorPageViewController;


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
    
    //Setup score background colors
    self.homeColor = [UIColor blueColor];
    self.visitorColor = [UIColor orangeColor];
    
    [self initializeHomeScore];
    [self initializeVisitorScore];
    [self resetGameKillAce];
    
}

- (void)initializeHomeScore
{
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

- (void)resetGameKillAce
{
    //Resets Game, Kill, and Ace to 0
    self.gameNumber.text = @"1";
    self.killNumber.text = @"0";
    self.aceNumber.text = @"0";
}


#pragma mark - Button Presses

- (IBAction)gamePressed
{
    //Grab the game number and add 1 but shouldn't be more than 3
    if (![self.gameNumber.text isEqualToString:@"3"]) {
        int lableNum = [self.gameNumber.text intValue];
        lableNum = lableNum + 1;
        self.gameNumber.text = [NSString stringWithFormat:@"%d", lableNum];
        
        //Reset the scores to start a new game
        [self initializeHomeScore];
        [self initializeVisitorScore];
    }
}

- (IBAction)killsPressed
{
    int lableNum = [self.killNumber.text intValue];
    lableNum = lableNum + 1;
    self.killNumber.text = [NSString stringWithFormat:@"%d", lableNum];
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

#pragma mark - Screen Action Buttons




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
