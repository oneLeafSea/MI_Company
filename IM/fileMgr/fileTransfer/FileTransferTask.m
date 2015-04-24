//
//  FileTransferTask.m
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FileTransferTask.h"
#import "Utils.h"
#import "AFNetworking.h"
#import "FileBlockPorter.h"
#import "FileBlocksMgr.h"
#import "NSDate+Common.h"
#import "LogLevel.h"
#import "FileHash.h"
#import "NSUUID+StringUUID.h"
#import "Encrypt.h"


static const int kMaxFileBlockPorters = 5;
static const NSUInteger kDefaultBlockSz = 1024*1024;
static const NSUInteger kFileTransferBlockCount = 3;

@interface FileTransferTask() <FileBlockPorterDelegate> {
    NSString *m_fileName;
    NSString *m_urlString;
    NSDictionary *m_options;
    unsigned long long m_sz;
    dispatch_queue_t m_taskQueue;
    FileTransferTaskType m_type;
    unsigned long long m_offset;
    unsigned long long m_tranfered;
    NSMutableArray *m_porter;
    FileBlocksMgr *m_blocksMgr;
    NSString *m_checkUrlString;
}
@end

@implementation FileTransferTask

- (instancetype) initWithFileName:(NSString *)fileName
                        urlString:(NSString *)urlString
                   checkUrlString:(NSString *)checkUrlString
                         taskType:(FileTransferTaskType)taskType
                          options:(NSDictionary *)options{
    if (self = [super init]) {
        NSAssert(fileName, @"file name is nil");
        m_fileName = [fileName copy];
        m_urlString = [urlString copy];
        m_options = [options copy];
        m_type = taskType;
        m_porter = [[NSMutableArray alloc] initWithCapacity:kMaxFileBlockPorters];
        m_checkUrlString = [checkUrlString copy];
        _taskId = [NSUUID uuid];
    }
    return self;
}

- (void) start {
    m_taskQueue = dispatch_queue_create([[NSString stringWithFormat:@"fileTransferQueue:%@", self.taskId] UTF8String], NULL);
    dispatch_async(m_taskQueue, ^{
        NSError *err = nil;
        if (m_type == FileTransferTaskTypeUpload) {
            m_sz = [Utils fileSizeAtPath:[self getFilePath] error:&err];
            if (err) {
                DDLogError(@"ERROR: file transfer get file sz.");
                if ([self.delegate respondsToSelector:@selector(FileTransferTask:finished:error:)]) {
                    [self.delegate FileTransferTask:self finished:NO error:err];
                }
                return;
            }
        } else {
            NSString *filePath = [self getFilePath];
            BOOL isDir = YES;
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
                if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
                    DDLogError(@"ERROR: file transfer create file:%@.", [filePath lastPathComponent]);
                }
            }
        }
        [self notifyFileServerStart];
    });
}

- (void) stop {
    
}

- (NSString *)fileName {
    return m_fileName;
}



- (NSString *)getFilePath {
    NSString *path = [m_options objectForKey:@"path"];
    return path;
}

- (BOOL) notifyFileServerStart {
    
    NSDictionary *params = @{
                             @"filename":m_fileName,
                             @"offset":[NSNumber numberWithUnsignedInteger:0],
                             @"block-size":[NSNumber numberWithUnsignedInteger:0],
                             @"timestamp":[[NSDate Now] formatWith:nil],
                             @"filesize":[NSNumber numberWithUnsignedLongLong:(m_type == FileTransferTaskTypeUpload) ? m_sz : 0]
                             };
    
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *key = [m_options objectForKey:@"key"];
    NSString *iv = [m_options objectForKey:@"iv"];
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:qid forHTTPHeaderField:@"qid"];
    [manager.requestSerializer setValue:[m_options objectForKey:@"token"] forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:sign forHTTPHeaderField:@"signature"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:m_urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(m_taskQueue, ^{
                NSHTTPURLResponse *resp = operation.response;
                if (m_type == FileTransferTaskTypeDownload) {
                    NSString *val = [[resp allHeaderFields] valueForKey:@"Fl"];
                    m_sz = [val intValue];
                }
                [self startTransfer];
            });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(m_taskQueue, ^{
            NSLog(@"%@", error);
            DDLogError(@"ERROR: %s. %@", __PRETTY_FUNCTION__, error);
            if ([self.delegate respondsToSelector:@selector(FileTransferTask:finished:error:)]) {
                [self.delegate FileTransferTask:self finished:NO error:error];
            }
        });
    }];
    return YES;
}


- (NSError*) genErrorWithCode:(int) errCode desc:(NSString *)desc {
    NSError *err = [NSError errorWithDomain:@"File Transefer task" code:errCode userInfo:@{@"desc":desc}];
    return err;
}

- (void) startTransfer {
    NSString *filePath = [m_options objectForKey:@"path"];
    m_blocksMgr = [[FileBlocksMgr alloc] initWithFilePath:filePath filesz:m_sz defaultBlockSz:kDefaultBlockSz fileName:m_fileName];
    for (int n = 0; n < kMaxFileBlockPorters; n++) {
        FileBlock *block = [m_blocksMgr getNotTranferedBlock];
        if (!block) {
            break;
        }
        FileBlockPorter *porter = [[FileBlockPorter alloc] init];
        porter.delegate = self;
        [porter transferWithUrlString:m_urlString block:block isUpload:(m_type == FileTransferTaskTypeUpload)  fileQueue:m_taskQueue options:m_options];
    }
    
}

- (void) endTransfer {
    NSString *filePath = [self getFilePath];
    NSString *md5 = [FileHash md5HashOfFileAtPath:filePath];
    if (!md5) {
        DDLogError(@"%@ md5 is nil", [filePath lastPathComponent]);
        return;
    }
    NSDictionary *params = @{
                             @"token":[m_options objectForKey:@"token"],
                             @"signature":[m_options objectForKey:@"signature"],
                             @"filename":m_fileName,
                             @"timestamp":[[NSDate Now] formatWith:nil],
                             @"filesize":[NSNumber numberWithUnsignedLongLong:(m_type == FileTransferTaskTypeUpload) ? m_sz : 0],
                             @"md5":md5,
                             @"end":@YES
                             };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:m_checkUrlString parameters:params constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(FileTransferTask:finished:error:)]) {
            [self.delegate FileTransferTask:self finished:YES error:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(FileTransferTask:finished:error:)]) {
            [self.delegate FileTransferTask:self finished:NO error:[self genErrorWithCode:4000 desc:@"md5 check error."]];
        }
    }];
}

#pragma mark - file blocke porter delegate.

- (void)FileBlockPorter:(FileBlockPorter *)porter block:(FileBlock *)block finished:(BOOL)finished error:(NSError *)error {
    if (finished) {
//         block.status = FileBlockStatusTransfered;
        [m_blocksMgr updateBlock:block finished:YES];
        if ([m_blocksMgr isEnd]) {
            DDLogWarn(@"INFO:file path:%@ transfered.", [[self getFilePath] lastPathComponent]);
            BOOL ret = [m_blocksMgr removeBlockInfo];
            if (!ret) {
                DDLogError(@"ERROR: remove blocks info.");
                if ([self.delegate respondsToSelector:@selector(FileTransferTask:finished:error:)]) {
                    [self.delegate FileTransferTask:self finished:NO error:[self genErrorWithCode:4000 desc:@"delete blocks info file error."]];
                }
                return;
            }
            [self endTransfer];
            return;
        }
        FileBlock *newBlock = [m_blocksMgr getNotTranferedBlock];
        if (newBlock) {
            [porter transferWithUrlString:m_urlString block:newBlock isUpload:(m_type == FileTransferTaskTypeUpload) fileQueue:m_taskQueue options:m_options];
        } else {
            porter.busy = NO;
        }
    } else {
        block.retryCount++;
        if (block.retryCount >= kFileTransferBlockCount) {
            if ([self.delegate respondsToSelector:@selector(FileTransferTask:finished:error:)]) {
                [self.delegate FileTransferTask:self finished:NO error:[self genErrorWithCode:4000 desc:@"chunk 超过重试次数."]];
            }
        } else {
            [porter transferWithUrlString:m_urlString block:block isUpload:(m_type == FileTransferTaskTypeUpload) fileQueue:m_taskQueue options:m_options];
        }
    }
}




- (NSError *)genErrString:(NSString *)errDesc code:(NSInteger)code {
    NSError *err = [NSError errorWithDomain:@"file tranfer Task" code:code userInfo:@{@"desc":errDesc}];
    return err;
}


@end
