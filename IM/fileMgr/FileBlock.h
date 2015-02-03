//
//  FileBlock.h
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt32, FileBlockStatus) {
    FileBlockStatusNotTransfered,
    FileBlockStatusTransfering,
    FileBlockStatusTransfered
};

@interface FileBlock : NSObject

- (instancetype)initWithFilPath:(NSString *)filePath
                           size:(NSUInteger)size
                         offset:(unsigned long long)offset
                       fileName:(NSString *)fileName
                         status:(FileBlockStatus)status
                         fileSz:(unsigned long long)fileSz;

- (instancetype)initWithDict:(NSDictionary *)dict filePath:(NSString *)path;

@property(nonatomic, readonly) unsigned long long offset;
@property(nonatomic, readonly) NSUInteger size;
@property(nonatomic, readonly) NSString *filePath;
@property(nonatomic, readonly) NSString *fileName;
@property(nonatomic) FileBlockStatus status;
@property(nonatomic) unsigned long long fileSz;

@property(atomic) NSUInteger retryCount;

- (NSDictionary *)Info;

@end
