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


+ (void)alertWithTip:(NSString *)tip {
    [[[UIAlertView alloc] initWithTitle:tip message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

+ (unsigned long long)fileSizeAtPath:(NSString *)path error:(NSError **)error {
    NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
    if (*error) {
        return 0;
    }
    unsigned long long fileSz = [fileDict fileSize];
    return fileSz;
}

+ (NSData *)readFileAtPath:(NSString *)path
                offset:(unsigned long long)offset
                  size:(NSUInteger)size {
    NSFileHandle *fHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!fHandle) {
        return nil;
    }
    [fHandle seekToFileOffset:offset];
    NSData *data = [fHandle readDataOfLength:size];
    [fHandle closeFile];
    return data;
}

+ (BOOL)writeFileAtPath:(NSString *)path
                   data:(NSData *)data
                 offset:(unsigned long long)offset {
    NSFileHandle *fHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!fHandle) {
        return NO;
    }
    [fHandle seekToFileOffset:offset];
    [fHandle writeData:data];
    [fHandle closeFile];
    return YES;
}


@end
