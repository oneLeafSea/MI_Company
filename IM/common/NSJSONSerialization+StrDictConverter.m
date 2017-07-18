//
//  NSJSONSerialization+StrDictConverter.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "NSJSONSerialization+StrDictConverter.h"

@implementation NSJSONSerialization (StrDictConverter)

+ (NSString *)jsonStringFromDict: (NSDictionary *)jsonDict {
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

+ (NSString *)jsonStringFromArray:(NSArray *)jsonArray {
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

+ (id)objFromJsonString:(NSString *)jsonStr {
    NSError *err = nil;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    return jsonDict;
}

@end
