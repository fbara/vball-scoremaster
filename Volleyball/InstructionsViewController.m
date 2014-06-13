//
//  InstructionsViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 6/12/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "InstructionsViewController.h"

@interface InstructionsViewController ()

@end

@implementation InstructionsViewController

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
    
    for(UIView* view in self.view.subviews)
    {
        if([view isKindOfClass:[UITextView class]] && view.restorationIdentifier)
        {
            UITextView* textView = (UITextView*)view;
            NSString *textViewName = [NSString stringWithFormat:@"%@.text",textView.restorationIdentifier];
            textView.text = NSLocalizedStringFromTable(textViewName, @"Main", nil);
            //change this to be the same as the name of your storyboard ^^^
        }
    }
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
