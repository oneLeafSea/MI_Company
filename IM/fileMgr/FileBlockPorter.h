//
//  FileBlockPorter.h
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileBlock.h"

@protocol FileBlockPorterDelegate;

@interface FileBlockPorter : NSObject

- (void) transferWithUrlString:(NSString *)urlString
                         block:(FileBlock *)block
                      isUpload:(BOOL)isUpload
                     fileQueue:(dispatch_queue_t)queue
                       options:(NSDictionary *)options;

@property(weak) id<FileBlockPorterDelegate> delegate;

@property(atomic) BOOL busy;

@end

@protocol FileBlockPorterDelegate <NSObject>

- (void)FileBlockPorter:(FileBlockPorter *)porter block:(FileBlock *)block finished:(BOOL)finished error:(NSError *)error;

@end