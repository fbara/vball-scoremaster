//
//  NSUserDefaults+Extension.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 10/22/15.
//  Copyright © 2015 BaraLabs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Extension)

- (void)setIndexPath:(NSIndexPath *)value forKey:(NSString *)defaultName;
- (NSIndexPath *)indexPathForKey:(NSString *)defaultName;

@end
