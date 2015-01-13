//
//  Utils.h
//  WH
//
//  Created by 郭志伟 on 14-10-22.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)documentPath;


+ (BOOL)EnsureDirExists:(NSString *)path;

+ (NSData *)bsonData:(NSDictionary *)dict;
+ (NSDictionary *)decodeBsonData:(NSData *)bsonData;

+ (id)jsonCollectionFromString:(NSString *)jsonString;

+ (NSData *)jsonDataFromDict:(NSDictionary *)dict;
+ (NSData *)jsonDataFromArray:(NSArray *)array;

+ (NSDictionary*)dictFromJsonData:(NSData *)data;
+ (NSArray *)arrayFromJsonData:(NSData *)data;

+ (NSString *)uuid;

+ (void)alertWithTip:(NSString *)tip;

@end
