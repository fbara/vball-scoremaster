//
//  SettingsViewController.m
//  Volleyball
//
//  Created by AppleAir on 5/20/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
{
    BOOL sendNotifications;
    CGPoint startingPoint;
}

#pragma mark - Initialize Settings
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Setup the scroll view
    [settingsScrollView setScrollEnabled:YES];
    [settingsScrollView setContentSize:CGSizeMake(568, 350)];
    // Set the delegate of the text fields
    self.nameOfPlayer.delegate = self;
    self.notificationName.delegate = self;
    // Create a tap recognizer to dismiss the keyboard when the user taps
    // outside the text fields
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    // Get the starting point of the scroll view so we can return there after text entry
    CGRect size = settingsScrollView.frame;
    startingPoint = (CGPointMake(size.origin.x, size.origin.y));
}

#pragma mark - UI Elements

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Controls -
#pragma mark -Save Settings

- (IBAction)saveSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Get Yes or No for notifications
    if (sendNotifications) {
        [defaults setObject:@"On" forKey:@"enableNotifications"];
        [self setNotificationFields:YES];
    } else {
        [defaults setObject:@"Off" forKey:@"enableNotifications"];
        [self setNotificationFields:FALSE];
    }
    

    
    //Set the home team color
    UIColor *colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    colorHome = self.homeTeamColor.backgroundColor;
    NSData *colorHomeData = [NSKeyedArchiver archivedDataWithRootObject:colorHome];
    [defaults setObject:colorHomeData forKey:@"homeTeamColor"];
    
    //Set the visiting team color
    UIColor *colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    colorVisitor = self.visitingTeamColor.backgroundColor;
    NSData *colorVisitorData = [NSKeyedArchiver archivedDataWithRootObject:colorVisitor];
    [defaults setObject:colorVisitorData forKey:@"visitorTeamColor"];
    
    //Set the player name, if entered
    [defaults setObject:self.nameOfPlayer.text forKey:@"playerNameForNotifications"];
    
    //Set the notification phone number
    [defaults setObject:self.notificationName.text forKey:@"phoneNumberForNotification"];
    
    //Make sure everything synchronized correctly
    if(![defaults synchronize]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings not saved"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        //Show a message that the settings have been saved
        self.settingsSavedNotification.hidden = NO;
        [self performSelector:@selector(hideSaveNotification)
                   withObject:nil
                   afterDelay:5.0];
        
    }
    // Get the starting point of the scroll view so we can return there after text entry
    CGRect size = settingsScrollView.frame;
    startingPoint = (CGPointMake(size.origin.x, size.origin.y));
    
    
}

- (void)hideSaveNotification
{
    self.settingsSavedNotification.hidden = YES;
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y);
    [settingsScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view endEditing:YES];
    //[settingsScrollView setContentOffset:CGPointZero animated:YES];
    [settingsScrollView setContentOffset:CGPointMake(0, -40)];
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

- (void)dismissKeyboard
{
    [self.notificationName resignFirstResponder];
    [self.nameOfPlayer resignFirstResponder];
}

/*!
 * @discussion Restrict the textFiled to a phone number format: ex. 555-555-5555
 * @param textField The text field that the user is typing in and that should be a phone number.
 * @param range The length of the phone number.
 * @param string Takes the numbers the user is entering and converts them to the phone.
 * number format
 * @return BOOL Returns whether or not the conversion to the phone number 
 * format was successful or not.
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //If this isn't a phone number entry field, return YES to exit
    if (textField.tag == 1) {
        return YES;
    }

    // All digits entered
    if (range.location == 14) {
        return NO;
    }
    
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }
    
    // Auto-add hyphen and parentheses
    if (range.length == 0 && range.location == 3 &&![[textField.text substringToIndex:1] isEqualToString:@"("]) {
        textField.text = [NSString stringWithFormat:@"(%@)-%@", textField.text,string];
        return NO;
    }
    if (range.length == 0 && range.location == 4 &&[[textField.text substringToIndex:1] isEqualToString:@"("]) {
        textField.text = [NSString stringWithFormat:@"%@)-%@", textField.text,string];
        return NO;
    }
    
    // Auto-add 2nd hyphen
    if (range.length == 0 && range.location == 9) {
        textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen and parentheses when deleting its trailing digit
    if (range.length == 1 &&
        (range.location == 10 || range.location == 1)){
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }
    if (range.length == 1 && range.location == 6){
        range.location=range.location-2;
        range.length = 3;
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }
    return YES;
}

#pragma mark - Enable/Disable Text Fields

- (void)setNotificationFields:(BOOL)enable
{
    for (UILabel *labels in self.notificationLabels) {
        labels.enabled = enable;
    }
    for (UITextField *textField in self.notificationTextEntries) {
        textField.enabled = enable;
    }
}

- (IBAction)notificationControl:(id)sender;
{
    if ([sender isOn]) {
        sendNotifications = YES;
        [self setNotificationFields:YES];
    } else {
        sendNotifications = NO;
        [self setNotificationFields:FALSE];
    }
}

#pragma mark -Team Background Colors

/*!
 * @discussion The background color of the home team's score
 * @param sender This param is not used.
 */
- (IBAction)homeTeamBackgroundColor:(id)sender
{
    //Change the button background color each time the button is tapped
    UIColor *homeButtonColor;
    homeButtonColor = [self getRandomColor];
    self.homeTeamColor.backgroundColor = homeButtonColor;
}

/*!
 * @discussion The background color of the visiting team's score
 * @param sender This param is not used.
 */
- (IBAction)visitingTeamBackgroundColor:(id)sender
{
    //Change the button background color each time the button is tapped
    UIColor *visitingButtonColor;
    visitingButtonColor = [self getRandomColor];
    self.visitingTeamColor.backgroundColor = visitingButtonColor;

}

/*!
 * @discussion Generate and return a random color
 * @return UIColor This color will be different each time the function is called
 */
- (UIColor *)getRandomColor
{
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    
    UIColor *color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    return color;
}

/*!
 * @discussion During viewWillAppear, grab the latest settings in case they were updated
 * @param animated Animate the view when it appears
 */
- (void)viewWillAppear:(BOOL)animated
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults stringForKey:@"enableNotifications"] isEqualToString:@"On"]) {
        self.notificationSwitch.on = YES;
        for (UILabel *label in self.notificationLabels) {
            label.enabled = YES;
        }
        for (UITextField *text in self.notificationTextEntries) {
            text.enabled = YES;
        }
    } else {
        self.notificationSwitch.on = NO;
        for (UILabel *label in self.notificationLabels) {
            label.enabled = NO;
        }
        for (UITextField *text in self.notificationTextEntries) {
            text.enabled = NO;
        }
    }
    
    //Get the name of the player
    self.nameOfPlayer.text = [defaults stringForKey:@"playerNameForNotifications"];
    
    //Get the phone number of the person to notify
    self.notificationName.text = [defaults stringForKey:@"phoneNumberForNotification"];
    
    //Get home team background colors
    UIColor *colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theHomeData = [[NSUserDefaults standardUserDefaults] dataForKey:@"homeTeamColor"];
    if (theHomeData != nil) {
        colorHome = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theHomeData];
    } else {
        colorHome = [UIColor blueColor];
    }
    self.homeTeamColor.backgroundColor = colorHome;
    
    //Get visiting team background colors
    UIColor *colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theVisitorData = [[NSUserDefaults standardUserDefaults] dataForKey:@"visitorTeamColor"];
    if (theVisitorData != nil) {
        colorVisitor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theVisitorData];
    } else {
        colorVisitor = [UIColor orangeColor];
    }
    self.visitingTeamColor.backgroundColor = colorVisitor;
    //[defaults synchronize];
    if(![defaults synchronize]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings could not be saved"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [super viewWillAppear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
