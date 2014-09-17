//
//  PhoneNumberFormatter.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 7/17/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//
//  Created by Ahmed Abdelkader on 1/22/10.

//  This work is licensed under a Creative Commons Attribution 3.0 License.

#import "PhoneNumberFormatter.h"

@implementation PhoneNumberFormatter

- (id)init {
    
    NSArray *usPhoneFormats = [NSArray arrayWithObjects:
                               @"+1 (###) ###-####",
                               @"1 (###) ###-####",
                               @"011 $",
                               @"###-####",
                               @"(###) ###-####", nil];

    NSArray *ukPhoneFormats = [NSArray arrayWithObjects:
                               @"+44 ##########",
                               @"00 $",
                               @"0### - ### ####",
                               @"0## - #### ####",
                               @"0#### - ######", nil];

    NSArray *jpPhoneFormats = [NSArray arrayWithObjects:
                               @"+81 ############",
                               @"001 $",
                               @"(0#) #######",
                               @"(0#) #### ####", nil];
    NSArray *esPhoneFormats = [NSArray arrayWithObjects:
                               @"+34 6## ### ###",
                               @"+34 7## ### ###", nil];

    predefinedFormats = [[NSDictionary alloc] initWithObjectsAndKeys:
                         usPhoneFormats, @"English (United States)",
                         ukPhoneFormats, @"English (United Kingdom)",
                         jpPhoneFormats, @"Japanese (Japan)",
                         esPhoneFormats, @"Spanish (Spain)",
                         nil];
    return self;
}

- (NSString *)format:(NSString *)phoneNumber withLocale:(NSString *)locale {
    NSArray *localeFormats = [predefinedFormats objectForKey:locale];
    
    if(localeFormats == nil) return phoneNumber;
    
    NSString *input = [self strip:phoneNumber];
    
    for(NSString *phoneFormat in localeFormats) {
        int i = 0;
        NSMutableString *temp = [[NSMutableString alloc] init];
        for(int p = 0; temp != nil && i < [input length] && p < [phoneFormat length]; p++) {
            char c = [phoneFormat characterAtIndex:p];
            BOOL required = [self canBeInputByPhonePad:c];
            char next = [input characterAtIndex:i];
            
            switch(c) {
                case '$':
                    p--;
                    [temp appendFormat:@"%c", next]; i++;
                    break;
                case '#':
                    if(next < '0' || next > '9') {
                        temp = nil;
                        break;
                    }
                    [temp appendFormat:@"%c", next]; i++;
                    break;
                default:
                    if(required) {
                        if(next != c) {
                            temp = nil;
                            break;
                        }
                        [temp appendFormat:@"%c", next]; i++;
                    } else {
                        [temp appendFormat:@"%c", c];
                        if(next == c) i++;
                    }
                    break;
            }
        }
        
        if(i == [input length]) {
            return temp;
        }
    }
    return input;
}



- (NSString *)strip:(NSString *)phoneNumber {
    
    NSMutableString *res = [[NSMutableString alloc] init];
    
    for(int i = 0; i < [phoneNumber length]; i++) {
        char next = [phoneNumber characterAtIndex:i];
        if([self canBeInputByPhonePad:next])
            [res appendFormat:@"%c", next];
    }
    return res;
}

- (BOOL)canBeInputByPhonePad:(char)c {
    if(c == '+' || c == '*' || c == '#') return YES;
    if(c >= '0' && c <= '9') return YES;
    return NO;
}

@end