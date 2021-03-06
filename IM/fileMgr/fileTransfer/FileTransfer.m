//
//  FileTransfer.m
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FileTransfer.h"
#import "AFNetworking.h"
#import "Utils.h"
#import "FileTransferTask.h"

static int kFileMaxTask = 5;

@interface FileTransfer() <FileTransferTaskDelegate> {
    dispatch_queue_t m_fileTransferQueue;
    NSMutableArray  *m_transfingQueue;
    NSMutableArray  *m_waitingQueue;
}

@end

@implementation FileTransfer

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_fileTransferQueue = dispatch_queue_create("cn.com.rooten.im.filettransfer", NULL);
        m_transfingQueue = [[NSMutableArray alloc] initWithCapacity:kFileMaxTask];
        m_waitingQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)exsitTask:(NSString *)filename {
    __block BOOL ret = NO;
    [m_transfingQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FileTransferTask *task = obj;
        if ([task.fileName isEqualToString:filename]) {
            ret = YES;
            *stop = YES;
        }
    }];
    if (ret == YES) {
        return ret;
    }
    
    [m_waitingQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FileTransferTask *task = obj;
        if ([task.fileName isEqualToString:filename]) {
            ret = YES;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)downloadFileName:(NSString *)fileName
               urlString:(NSString *)urlString
          checkUrlString:(NSString *)checkUrlString
                 options:(NSDictionary *)options
              completion:(void(^)(BOOL finished, NSError *error))completion {
    dispatch_sync(m_fileTransferQueue, ^{
        FileTransferTask *task = [[FileTransferTask alloc] initWithFileName:fileName urlString:urlString checkUrlString:checkUrlString completeUrlString:nil taskType:FileTransferTaskTypeDownload options:options];
        task.delegate = self;
        task.completion = completion;
        if (m_transfingQueue.count >= kFileMaxTask) {
            [m_waitingQueue addObject:task];
        } else {
            [m_transfingQueue addObject:task];
            [task start];
        }
        
    });
}


- (void)uploadFileName:(NSString *)fileName
             urlString:(NSString *)urlString
        checkUrlString:(NSString *)checkUrlString
     completeUrlString:(NSString *)completeUrlString
               options:(NSDictionary *)options
            completion:(void(^)(BOOL finished, NSError *error))completion {
    dispatch_async(m_fileTransferQueue, ^{
        FileTransferTask *task = [[FileTransferTask alloc] initWithFileName:fileName urlString:urlString checkUrlString:checkUrlString completeUrlString:completeUrlString taskType:FileTransferTaskTypeUpload options:options];
        task.delegate = self;
        task.completion = completion;
        if (m_transfingQueue.count >= kFileMaxTask) {
            [m_waitingQueue addObject:task];
        } else {
            [m_transfingQueue addObject:task];
            [task start];
        }
        
    });
    
}

- (void)FileTransferTask:(FileTransferTask *)task finished:(BOOL) finished error:(NSError *)error {
    dispatch_async(m_fileTransferQueue, ^{
        task.completion(finished, error);
        [m_transfingQueue removeObject:task];
        if (m_waitingQueue.count > 0) {
            FileTransferTask *newTask = [m_waitingQueue objectAtIndex:0];
            [m_transfingQueue addObject:newTask];
            [m_waitingQueue removeObjectAtIndex:0];
            [newTask start];
        }
    });
}



@end
