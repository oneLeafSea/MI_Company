//
//  NSString+CheckNumeric.m
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "NSString+CheckNumeric.h"

@implementation NSString (CheckNumeric)

- (BOOL)isNumeric
{
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:self];
    return [alphaNums isSupersetOfSet:inStringSet];
}

@end
