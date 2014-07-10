//
//  ActionLabelTableViewController.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/7/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionLabelTableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic)NSString *firstActionName;
@property (weak, nonatomic)NSString *secondActionName;
@property (strong, nonatomic)IBOutlet NSString *selectedActionName;
@property NSInteger selectedActionRow;

@end
