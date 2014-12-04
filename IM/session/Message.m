//
//  message.m
//  WH
//
//  Created by 郭志伟 on 14-10-12.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Message.h"

#import "ObjCMongoDB.h"
#import "LogLevel.h"
#import "NSJSONSerialization+StrDictConverter.h"


@interface Message()


@end

@implementation Message


- (instancetype)initWithType:(UInt32)type msgType:(UInt32)msgType {
    if (self = [super init]) {
        _type = type;
        _msgType = msgType;
    }
    return self;
}

#if DEBUG
- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", NSStringFromClass([self class]));
}
#endif

@end

@implementation Message (Tool)

- (NSString *)uuid {
    NSUUID *uuid = [NSUUID UUID];
    NSString *ret = [uuid UUIDString];
    return ret;
}

- (NSData *)bsonData:(NSDictionary *)dict {
    NSData *data = [[dict BSONDocument] dataValue];
    return data;
}

- (NSDictionary *)decodeBsonData:(NSData *)bsonData {
    NSDictionary *dict = [BSONDecoder decodeDictionaryWithData:bsonData];
    return dict;
}

- (id)jsonDictFromString:(NSString *)jsonString {
    NSError *e = nil;
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &e];
    if (e) {
        DDLogWarn(@"parse json string err %@", e);
    }
    return JSON;
}

- (NSData *)jsonDataFromDict:(NSDictionary *)dict {
    NSString *str = [NSJSONSerialization jsonStringFromDict:dict];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
    
}
- (NSData *)jsonDataFromArray:(NSArray *)array {
    NSString *str = [NSJSONSerialization jsonStringFromArray:array];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSDictionary *)dictFromJsonData:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [self jsonDictFromString:str];
    return dict;
}

- (NSArray *)arrayFromJsonData:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [self jsonDictFromString:str];
    return arr;
}

@end
