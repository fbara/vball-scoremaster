//
//  DefaultScoreViewController.h
//  Volleyball
//
//  Created by Frank Bara on 5/16/14.
//  Copyright (c) 2014 BaraLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultScoreViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic) int score;

- (void)setScoreNumberSize:(CGFloat)numberSize;

@end
