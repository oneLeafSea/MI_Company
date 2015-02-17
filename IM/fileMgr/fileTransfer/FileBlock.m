//
//  FileBlock.m
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FileBlock.h"

@implementation FileBlock

- (instancetype)initWithFilPath:(NSString *)filePath
                           size:(NSUInteger)size
                         offset:(unsigned long long)offset
                       fileName:(NSString *)fileName
                         status:(FileBlockStatus)status
                         fileSz:(unsigned long long)fileSz {
    if (self = [super init]) {
        _filePath = filePath;
        _size = size;
        _offset = offset;
        _status = status;
        _fileName = fileName;
        _fileSz = fileSz;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict filePath:(NSString *)path {
    if (self = [super init]) {
        _filePath = path;//[dict objectForKey:@"block_filePath"];
        NSNumber *sz = [dict objectForKey:@"block_size"];
        _size = [sz unsignedIntegerValue];
        NSNumber *offset = [dict objectForKey:@"block_offset"];
        _offset = [offset unsignedLongLongValue];
        NSNumber *status = [dict objectForKey:@"block_status"];
        _status = [status unsignedIntValue];
        if (_status == FileBlockStatusTransfering) {
            _status = FileBlockStatusNotTransfered;
        }
        _fileName = [dict objectForKey:@"filename"];
        NSNumber *fileSz = [dict objectForKey:@"fileSz"];
        _fileSz = [fileSz unsignedLongLongValue];
    }
    return self;
}

- (NSDictionary *)Info {
    NSDictionary *blockInfo = @{
                                @"block_filePath":self.filePath,
                                @"block_size":[NSNumber numberWithUnsignedInteger:self.size],
                                @"block_offset":[NSNumber numberWithUnsignedLongLong:self.offset],
                                @"block_status":[NSNumber numberWithUnsignedInt:self.status],
                                @"filename":self.fileName,
                                @"filesz":[NSNumber numberWithUnsignedLongLong:self.fileSz]
                                };
    return blockInfo;
}

@end
