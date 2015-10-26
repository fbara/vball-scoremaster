//
//  NSUserDefaults+Extension.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 10/22/15.
//  Copyright © 2015 BaraLabs, LLC. All rights reserved.
//

#import "NSUserDefaults+Extension.h"

@implementation NSUserDefaults (Extension)

-(void)setIndexPath:(NSIndexPath *)value forKey:(NSString *)defaultName {
	[self setObject:@{@"row": @(value.row), @"section": @(value.section)} forKey:defaultName];
	
}

-(NSIndexPath *)indexPathForKey:(NSString *)defaultName {
	NSDictionary *dict = [self objectForKey:defaultName];
	
	return [NSIndexPath indexPathForRow:[dict[@"row"] integerValue]
							  inSection:[dict[@"section"] integerValue]];
}

@end
