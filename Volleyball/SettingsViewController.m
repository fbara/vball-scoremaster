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
    NSMutableArray *opponentNames;
    NSString *selectedOpponent;
    NSString *maxGamesSetting;

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
    opponentNames = [[NSMutableArray alloc] init];
    [opponentNames addObject:@"Plainfield North"];
    [opponentNames addObject:@"Plainfield Central"];
    [opponentNames addObject:@"Plainfield South"];
    [opponentNames addObject:@"Minooka"];
    [opponentNames addObject:@"Oswego East"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

#pragma mark - PickerView Settings

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedOpponent = [opponentNames objectAtIndex:row];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //Populates pickerview
    return [opponentNames objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //Number of items
    return [opponentNames count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //Number of components
    return 1;
}

#pragma mark - Controls

- (IBAction)saveSettings:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:maxGamesSetting forKey:@"number_of_matches"];
    [defaults setObject:selectedOpponent forKey:@"opponent"];
    
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

    //Make sure everything synchronized correctly
    if(![defaults synchronize]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings not saved"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

- (IBAction)numberOfGamesSegment:(id)sender
{
    if (self.gamesControl.selectedSegmentIndex == 0) {
        maxGamesSetting = @"1";
        
    } else if (self.gamesControl.selectedSegmentIndex == 1) {
        maxGamesSetting = @"2";

    } else if (self.gamesControl.selectedSegmentIndex == 2) {
        maxGamesSetting = @"3";

    }
}

- (IBAction)homeTeamBackgroundColor:(id)sender
{
    //Change the button background color each time the button is clicked
    UIColor *homeButtonColor;
    homeButtonColor = [self getRandomColor];

    self.homeTeamColor.backgroundColor = homeButtonColor;
}

- (IBAction)visitingTeamBackgroundColor:(id)sender
{
    UIColor *visitingButtonColor;
    visitingButtonColor = [self getRandomColor];
    
    self.visitingTeamColor.backgroundColor = visitingButtonColor;

}

- (UIColor *)getRandomColor
{
    //Generate a random color and return it
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    
    UIColor *color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    return color;
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}



- (void)viewWillAppear:(BOOL)animated
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //Get the max games segmented control
    maxGamesSetting = [defaults objectForKey:@"number_of_matches"];
    self.gamesControl.selectedSegmentIndex = [maxGamesSetting intValue] - 1;
    
    //Get home team background colors
    UIColor *colorHome = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theHomeData = [[NSUserDefaults standardUserDefaults] dataForKey:@"homeTeamColor"];
    if (theHomeData != nil) {
        colorHome = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theHomeData];
    }
    self.homeTeamColor.backgroundColor = colorHome;
    
    //Get visiting team background colors
    UIColor *colorVisitor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSData *theVisitorData = [[NSUserDefaults standardUserDefaults] dataForKey:@"visitorTeamColor"];
    if (theVisitorData != nil) {
        colorVisitor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theVisitorData];
    }
    self.visitingTeamColor.backgroundColor = colorVisitor;
    
    //Get the opponent
    selectedOpponent = [[NSString alloc] initWithString:[defaults objectForKey:@"opponent"]];
    int selectedRow = [opponentNames indexOfObject:selectedOpponent];
    [self.opponentPicker selectRow:selectedRow
                       inComponent:0
                          animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
