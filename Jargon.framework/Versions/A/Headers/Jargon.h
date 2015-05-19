//
//  Colatris.h
//  Colatris
//
//  Created by Emilien on 2015-04-14.
//  Copyright (c) 2015 Parlance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define JNOptionsDialogEnabled      @"dialogEnabled"
#define JNOptionsLoggingLevel       @"loggingLevel"
#define JNOptionsServingFrequency   @"servingFrequency"

typedef NS_ENUM(NSUInteger, JNLoggingLevel) {
JNLoggingLevelNone      = 0,
JNLoggingLevelError     = 1,
JNLoggingLevelWarn      = 2,
JNLoggingLevelInfo      = 3,
JNLoggingLevelDebug     = 4,
JNLoggingLevelVerbose   = 5
};

typedef NS_ENUM(NSUInteger, JNServingFrequency) {
JNServingNone       = 0,
JNServingOnce       = 1,
JNServingDaily      = 2,
JNServingWeekly     = 3,
};

@interface Jargon : NSObject

+ (void)startWithAPIKey:(NSString *)apikey andOptions:(NSDictionary *)options;
+ (NSLocale *)locale;

@end
