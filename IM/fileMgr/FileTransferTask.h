//
//  FileTransferTask.h
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt32, FileTransferTaskType) {
    FileTransferTaskTypeUpload,
    FileTransferTaskTypeDownload
};

@protocol FileTransferTaskDelegate;

@interface FileTransferTask : NSObject

- (instancetype) initWithFileName:(NSString *)fileName
                        urlString:(NSString *)urlString
                   checkUrlString:(NSString *)checkUrlString
                         taskType:(FileTransferTaskType)taskType
                          options:(NSDictionary *)options;

- (void) start;
- (void) stop;


@property(nonatomic, copy)void(^completion)(BOOL finished, NSError *error);
@property(readonly)NSString *taskId;

@property(weak) id<FileTransferTaskDelegate> delegate;

@end


@protocol FileTransferTaskDelegate <NSObject>

- (void)FileTransferTask:(FileTransferTask *)task finished:(BOOL) finished error:(NSError *)error;

@end