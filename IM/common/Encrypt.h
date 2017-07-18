//
//  Encrypt.h
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encrypt : NSObject

+ (NSString *)encodeWithKey:(NSString *)key iv:(NSString *)iv data:(NSData *)data error:(NSError **)error;

+ (NSData *)decodeWithKey:(NSString *)key iv:(NSString *)iv base64Str:(NSString *)base64Str error:(NSError **)error;

@end
