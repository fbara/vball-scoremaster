//
//  EATutorialViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/23/18.
//  Copyright © 2018 BaraLabs, LLC. All rights reserved.
//

#import "EATutorialViewController.h"

EAIntroPage *page1, *page2, *page3, *page4;
static NSString *page1Text = @"This is the first page of the intro walkthru!";
static NSString *page2Text = @"This is the second page of the intro walkthru!";
static NSString *page3Text = @"This is the third page of the intro walkthru!";
static NSString *page4Text = @"This is the fourth page of the intro walkthru!";

@implementation EATutorialViewController

- (void)showIntroPages {
    page1 = [EAIntroPage page];
    page1.title = NSLocalizedString(@"Page 1 Title", @"Page 1 title");
    page1.desc = page1Text;
    
}


@end
