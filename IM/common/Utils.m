//
//  Utils.m
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Utils.h"
#import "ObjCMongoDB.h"
#import "NSJSONSerialization+StrDictConverter.h"
#import "LogLevel.h"

@implementation Utils

+ (NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}


+ (BOOL)EnsureDirExists:(NSString *)path {
    BOOL ret = YES;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:path])
        return ret;
    NSArray *components = [path pathComponents];
    if (components.count == 0)
        return NO;
    NSString *subPath = [components objectAtIndex:0];
    NSError *error = [[NSError alloc]init];
    for (NSInteger n = 1; n < components.count; n++) {
        subPath = [subPath stringByAppendingPathComponent:[components objectAtIndex:n]];
        if ([fileMgr fileExistsAtPath:subPath])
            continue;
        if ([[NSFileManager defaultManager]createDirectoryAtPath:subPath
                                     withIntermediateDirectories:NO
                                                      attributes:nil
                                                           error:&error]) {
            continue;
        }
        else {
            
            NSLog(@"%@", error.localizedDescription);
            ret = NO;
            break;
        }
        
    }
    return ret;
}



+ (NSData *)bsonData:(NSDictionary *)dict {
    NSData *data = [[dict BSONDocument] dataValue];
    return data;
}

+ (NSDictionary *)decodeBsonData:(NSData *)bsonData {
    NSDictionary *dict = [BSONDecoder decodeDictionaryWithData:bsonData];
    return dict;
}

+ (id)jsonCollectionFromString:(NSString *)jsonString {
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

+ (NSData *)jsonDataFromDict:(NSDictionary *)dict {
    NSString *str = [NSJSONSerialization jsonStringFromDict:dict];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
    
}
+ (NSData *)jsonDataFromArray:(NSArray *)array {
    NSString *str = [NSJSONSerialization jsonStringFromArray:array];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+ (NSDictionary *)dictFromJsonData:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [self jsonCollectionFromString:str];
    return dict;
}

+ (NSArray *)arrayFromJsonData:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [self jsonCollectionFromString:str];
    return arr;
}

+ (NSString *)uuid {
    NSUUID *uuid = [NSUUID UUID];
    NSString *ret = [uuid UUIDString];
    return ret;
}


@end