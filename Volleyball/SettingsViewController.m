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
    self.homeTeamColor.backgroundColor = [self getRandomColor];

}

- (IBAction)visitingTeamBackgroundColor:(id)sender
{
    self.visitingTeamColor.backgroundColor = [self getRandomColor];

}

- (UIColor *)getRandomColor
{
    //Generate a random color each time the button is pushed
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

    //Set the max games segmented control
    maxGamesSetting = [defaults objectForKey:@"number_of_matches"];
    self.gamesControl.selectedSegmentIndex = [maxGamesSetting intValue] - 1;
    
    //Set the opponent
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
