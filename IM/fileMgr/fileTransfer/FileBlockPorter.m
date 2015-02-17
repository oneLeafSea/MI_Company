//
//  FileBlockPorter.m
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FileBlockPorter.h"
#import "AFNetworking.h"
#import "Utils.h"
#import "NSDate+Common.h"
#import "LogLevel.h"

@implementation FileBlockPorter

- (void) uploadWithUrlString:(NSString *)urlString
                       block:(FileBlock *)block
                   fileQueue:(dispatch_queue_t)queue
                    options:(NSDictionary *)options {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *blockData = [Utils readFileAtPath:block.filePath offset:block.offset size:block.size];
        NSString *base64Data = [blockData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSDictionary *params = @{
                                @"token":[options objectForKey:@"token"],
                                @"signature":[options objectForKey:@"signature"],
                                @"filename":block.fileName,
                                @"offset":[NSNumber numberWithUnsignedLongLong:block.offset],
                                @"block-size":[NSNumber numberWithUnsignedInteger:blockData.length],
                                @"bin":base64Data,
                                @"timestamp":[[NSDate Now] formatWith:nil],
                                @"filesize":[NSNumber numberWithUnsignedLongLong:block.fileSz]
                                };
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:urlString parameters:params constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"uploaded fileName:%@ offset:%llu size:%lu", block.fileName, block.offset, (unsigned long)block.size);
            dispatch_async(queue, ^{
                if ([self.delegate respondsToSelector:@selector(FileBlockPorter:block:finished:error:)]) {
                    [self.delegate FileBlockPorter:self block:block finished:YES error:nil];
                }
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(queue, ^{
                if ([self.delegate respondsToSelector:@selector(FileBlockPorter:block:finished:error:)]) {
                    [self.delegate FileBlockPorter:self block:block finished:NO error:error];
                }
            });
        }];
    });
}

- (void) downloadWithUrlString:(NSString *)urlString
                         block:(FileBlock *)block
                     fileQueue:(dispatch_queue_t)queue
                       options:(NSDictionary *)options {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *params = @{
                                @"token":[options objectForKey:@"token"],
                                @"signature":[options objectForKey:@"signature"],
                                @"filename":block.fileName,
                                @"offset":[NSNumber numberWithUnsignedLongLong:block.offset],
                                @"block-size":[NSNumber numberWithUnsignedLongLong:block.size],
                                @"timestamp":[[NSDate Now] formatWith:nil]
                                };
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:urlString parameters:params constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"downloaded fileName:%@ offset:%llu size:%lu", block.fileName, block.offset, (unsigned long)block.size);
            NSData *data = responseObject;
            NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if (data.length == block.size) {
                [Utils writeFileAtPath:block.filePath data:data offset:block.offset];
            }
            dispatch_async(queue, ^{
                if ([self.delegate respondsToSelector:@selector(FileBlockPorter:block:finished:error:)]) {
                    [self.delegate FileBlockPorter:self block:block finished:YES error:nil];
                }
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(queue, ^{
                DDLogInfo(@"%@", error);
                DDLogInfo(@"download fail offset:%llu size:%lu", block.offset, (unsigned long)block.size);
                if ([self.delegate respondsToSelector:@selector(FileBlockPorter:block:finished:error:)]) {
                    [self.delegate FileBlockPorter:self block:block finished:NO error:error];
                }
            });
        }];
    });
}

- (void) transferWithUrlString:(NSString *)urlString
                         block:(FileBlock *)block
                      isUpload:(BOOL)isUpload
                     fileQueue:(dispatch_queue_t)queue
                       options:(NSDictionary *)options; {
    if (isUpload) {
        [self uploadWithUrlString:urlString block:block fileQueue:queue options:options];
    } else {
        [self downloadWithUrlString:urlString block:block fileQueue:queue options:options];
    }
}


@end
