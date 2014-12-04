//
//  NSJSONSerialization+StrDictConverter.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (StrDictConverter)

+ (NSString *)jsonStringFromDict: (NSDictionary *)jsonDict;

+ (NSString *)jsonStringFromArray:(NSArray *)jsonArray;

+ (id)objFromJsonString:(NSString *)jsonStr;

@end
