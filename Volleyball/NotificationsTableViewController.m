//
//  NotificationsTableViewController.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 3/30/16.
//  Copyright © 2016 BaraLabs, LLC. All rights reserved.
//

#import "NotificationsTableViewController.h"

@interface NotificationsTableViewController ()

@property (nonatomic, strong)UIPreviewActionGroup *previewActions;

@end

@implementation NotificationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSIndexPath* initialIndex = [NSIndexPath indexPathForRow:[defaults integerForKey:@"selectedNotificationRow"] inSection:0];
    if (initialIndex == nil) {
        initialIndex = 0;
    }
    [self.tableView selectRowAtIndexPath:initialIndex animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self tableView:self.tableView didSelectRowAtIndexPath:initialIndex];

}

#pragma mark - 3d Touch

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    NSArray *list = [[NSArray alloc] init];
    UIPreviewAction *score = [UIPreviewAction actionWithTitle:@"Score"
                                                          style:UIPreviewActionStyleDefault
                                                        handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
                                                            [self setOptions:@"Team" forKey:@"notificationsType" rowNumber:0];
                                                        }];
    UIPreviewAction *player = [UIPreviewAction actionWithTitle:@"Player"
                                                          style:UIPreviewActionStyleDefault
                                                        handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
                                                            [self setOptions:@"Player" forKey:@"notificationsType" rowNumber:1];
                                                        }];
    UIPreviewAction *blank = [UIPreviewAction actionWithTitle:@"Blank"
                                                          style:UIPreviewActionStyleDefault
                                                        handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
                                                            [self setOptions:@"Blank" forKey:@"notificationsType" rowNumber:2];
                                                        }];
    UIPreviewAction *NotifOn = [UIPreviewAction actionWithTitle:@"Notfication On"
                                                          style:UIPreviewActionStyleDefault
                                                        handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
                                                            [self setOptions:@"On" forKey:@"enableNotifications" rowNumber:3];
                                                        }];
    UIPreviewAction *NotifOff = [UIPreviewAction actionWithTitle:@"Notfication Off"
                                                           style:UIPreviewActionStyleDefault
                                                         handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
                                                             [self setOptions:@"Off" forKey:@"enableNotifications" rowNumber:4];
                                                             
                                                         }];
    list = @[score,player,blank,NotifOn,NotifOff];
    self.previewActions = [UIPreviewActionGroup actionGroupWithTitle:@"Notifications"
                                                                   style:UIPreviewActionStyleDefault
                                                                 actions:list];
    return list;

}

- (void)setOptions:(NSString *)object forKey:(NSString *)key rowNumber:(int)row {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults setInteger:row forKey:@"selectedNotificationRow"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    switch (indexPath.row) {
        case 0:
            [self setOptions:@"Team" forKey:@"notificationsType" rowNumber:0];
            break;
        case 1:
            [self setOptions:@"Player" forKey:@"notificationsType" rowNumber:1];
            break;
        case 2:
            [self setOptions:@"Blank" forKey:@"notificationsType" rowNumber:2];
            break;
        case 3:
            [self setOptions:@"On" forKey:@"enableNotifications" rowNumber:3];
            break;
        case 4:
            [self setOptions:@"Off" forKey:@"enableNotifications" rowNumber:4];
            break;
        default:
            break;
    }
}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell =
//    
//    return cell;
//}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
