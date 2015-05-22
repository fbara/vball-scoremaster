//
//  SupportTableViewController.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 8/20/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABXPromptView.h"
#import "ABXNotificationView.h"

@interface SupportTableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource,ABXPromptViewDelegate>

- (void)whichSegueWasUsed:(NSString *)segueName;

@end
