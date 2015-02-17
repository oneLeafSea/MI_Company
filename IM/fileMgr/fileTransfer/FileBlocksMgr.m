//
//  FileBlocksMgr.m
//  IM
//
//  Created by 郭志伟 on 15-1-30.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FileBlocksMgr.h"
#import "LogLevel.h"
#import "Utils.h"

static NSString *kBlocksSuffix = @".blocksInfo";

@interface FileBlocksMgr() {
    dispatch_queue_t    m_queue;
    unsigned long long  m_sz;
    NSUInteger          m_defaultBlockSz;
    NSString            *m_filePath;
    NSMutableArray      *m_blocks;
    NSString            *m_fileName;
}
@end


@implementation FileBlocksMgr

- (instancetype)initWithFilePath:(NSString *)filePath
                          filesz:(unsigned long long)sz
                  defaultBlockSz:(NSUInteger)defaultBlockSz
                        fileName:(NSString *)fileName {
    if (self = [super init]) {
        m_sz = sz;
        m_defaultBlockSz = defaultBlockSz;
        m_filePath = filePath;
        m_fileName = fileName;
        if (![self setup]) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)setup {
    m_queue = dispatch_queue_create([NSString stringWithFormat:@"cn.com.rooten.im.file_blocks_mgr.%@", m_filePath].UTF8String, NULL);
    m_blocks = [[NSMutableArray alloc] init];
    
    if (![self buildBlocks]) {
        return NO;
    }

    return YES;
}

- (BOOL)buildBlocks {
    NSString *blocksInfoPath = [self getBlocksInfoPath];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:blocksInfoPath isDirectory:&isDir]) {
        if (!isDir) {
            return [self loadBlocksAtPath:blocksInfoPath];
        } else {
            DDLogError(@"ERROR: %@ is Directory.", blocksInfoPath);
            return NO;
        }
    } else {
        if (![[NSFileManager defaultManager] createFileAtPath:blocksInfoPath contents:nil attributes:nil]) {
            return NO;
        }
        return [self creatBlocksAtPath:blocksInfoPath];
    }
}

- (BOOL)creatBlocksAtPath:(NSString *)path {
    unsigned long long blocksCount = m_sz / m_defaultBlockSz;
    NSUInteger left = m_sz % m_defaultBlockSz;
    NSUInteger n = 0;
    for (; n < blocksCount; n++) {
        FileBlock *block = [[FileBlock alloc] initWithFilPath:m_filePath size:m_defaultBlockSz offset:m_defaultBlockSz * n fileName:m_fileName status:FileBlockStatusNotTransfered fileSz:m_sz];
        [m_blocks addObject:block];
    }
    if (left > 0) {
        FileBlock *block = [[FileBlock alloc] initWithFilPath:m_filePath size:left offset:m_defaultBlockSz * n fileName:m_fileName status:FileBlockStatusNotTransfered fileSz:m_sz];
        [m_blocks addObject:block];
    }
    if (![self saveBlocksInfoAtPath:path]) {
        return NO;
    }
    return YES;
}

- (BOOL)removeBlockInfo {
    __block BOOL ret = YES;
    dispatch_sync(m_queue, ^{
        ret = [[NSFileManager defaultManager] removeItemAtPath:[self getBlocksInfoPath] error:nil];
    });
    return ret;
}

- (NSString *) getBlocksInfoPath {
    NSString *blocksInfoPath = [m_filePath stringByAppendingString:kBlocksSuffix];
    return blocksInfoPath;
}


- (BOOL)loadBlocksAtPath:(NSString *)path {
    __block BOOL ret = YES;
    dispatch_sync(m_queue, ^{
        NSDictionary *blockInfo = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!blockInfo) {
            ret = NO;
        } else {
            NSDictionary *blocks = [blockInfo objectForKey:@"blocks"];
            for (NSDictionary *b in blocks) {
                [m_blocks addObject:[[FileBlock alloc] initWithDict:b filePath:m_filePath]];
            }
        }
//        m_filePath = [blockInfo objectForKey:@"filePath"];
        NSNumber *filesz = [blockInfo objectForKey:@"filesz"];
        m_sz = [filesz unsignedLongLongValue];
        NSNumber *defaultBlockSz = [blockInfo objectForKey:@"defaultBlockSz"];
        m_defaultBlockSz = [defaultBlockSz unsignedIntegerValue];
    });
    return YES;
}

- (BOOL)saveBlocksInfoAtPath:(NSString *)path {
    __block BOOL ret = YES;
    dispatch_sync(m_queue, ^{
        NSDictionary *blocksInfo = [self genBlockInfo];
        ret = [blocksInfo writeToFile:path atomically:YES];
    });
    return ret;
}

- (void)update {
    NSString *blocksInfoPath = [m_filePath stringByAppendingString:kBlocksSuffix];
    [self saveBlocksInfoAtPath:blocksInfoPath];
}

- (NSDictionary *)genBlockInfo {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:m_filePath forKey:@"filePath"];
    [info setObject:[NSNumber numberWithUnsignedLongLong:m_sz] forKey:@"filesz"];
    [info setObject:[NSNumber numberWithUnsignedInteger:m_defaultBlockSz] forKey:@"defaultBlockSz"];
    
    NSMutableArray *blocks = [[NSMutableArray alloc] init];
    for (FileBlock *block in m_blocks) {
        NSDictionary *blockInfo = [block Info];
        [blocks addObject:blockInfo];
    }
    [info setObject:blocks forKey:@"blocks"];
    return info;
}

- (FileBlock *)getNotTranferedBlock {
    __block FileBlock *block = nil;
    dispatch_sync(m_queue, ^{
        for (FileBlock *b in m_blocks) {
            if (b.status == FileBlockStatusNotTransfered) {
                block = b;
                block.status = FileBlockStatusTransfering;
                break;
            }
        }
    });
    return block;
}

- (BOOL) isEnd {
    __block BOOL end = YES;
    dispatch_sync(m_queue, ^{
        for (FileBlock *b in m_blocks) {
            if (b.status == FileBlockStatusNotTransfered || b.status == FileBlockStatusTransfering) {
                end = NO;
                break;
            }
        }
    });
    return end;
}

@end
