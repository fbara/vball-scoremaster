//
//  SupportInstructionsViewController.m
//  VBall ScoreMaster
//
//  Created by AppleAir on 6/5/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SupportInstructionsViewController.h"

@interface SupportInstructionsViewController ()

@end

@implementation SupportInstructionsViewController

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
    // Do any additional setup after loading the view.
    
    self.supportText.text = NSLocalizedString(@"Thank you for using VBall ScoreMaster©.  There is Help text on the main page if you need assistance in using this app.  This app could not have been created without the help of Paul Dolce.  Thank you, Paul!  As with all apps, your reviews on the App Store will help with the continued development and improvement of VBall ScoreMaster©.  Please consider leaving a review, it helps other people who are looking for a scoring app.  For support requests or to submit ideas for this app, please contact support@baralabs.com.", nil);
    
    for(UIView* view in self.view.subviews)
    {
        if([view isKindOfClass:[UITextView class]] && view.restorationIdentifier)
        {
            UITextView* textView = (UITextView*)view;
            NSString *textViewName = [NSString stringWithFormat:@"%@.text",textView.restorationIdentifier];
            textView.text = NSLocalizedStringFromTable(textViewName, @"Main", nil);
            //change this to be the same as the name of the storyboard ^^^
        }
    }
}

- (IBAction)return:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
