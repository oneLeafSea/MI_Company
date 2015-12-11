//
//  RTFileTransfer.m
//  IM
//
//  Created by 郭志伟 on 15/6/17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTFileTransfer.h"
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "NSUUID+StringUUID.h"
#import "NSDate+Common.h"
#import "Encrypt.h"
#import "NSString+URL.h"
#import "LogLevel.h"


@implementation RTFileTransfer

+ (void)uploadFileWithServerUrl:(NSString *)serverUrl
                       filePath:(NSString *)filePath
                          token:(NSString *)token
                            key:(NSString *)key
                             iv:(NSString *)iv
                       progress:(void(^)(double progress))progress
                     completion:(void(^)(BOOL finished))cpt {
    
    __block NSString *fileName = [filePath lastPathComponent];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSError *err = nil;
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:serverUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"bin" fileName:[fileName URLEncodedString] mimeType:@"application/file" error:&error];
        if (error) {
            NSAssert(0, @"upload file path error.");
        }
    } error:&err];
    
    if (err) {
        NSAssert(0, @"multipartFormRequestWithMethod error.");
    }
    
    NSString *qid = [fileName stringByDeletingPathExtension];
    NSString *data = [NSString stringWithFormat:@"%@|%@|%@", qid, fileName, [[NSDate Now] formatWith:@"yyyy-MM-dd HH:mm:ss"]];
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[data dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [request setValue:[token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [request setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [request setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    [request setValue:[fileName URLEncodedString] forHTTPHeaderField:@"rc-fn"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (cpt) {
                                             cpt(YES);
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (cpt) {
                                             cpt(NO);
                                         }
                                         
                                     }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {

        double p = totalBytesWritten / (double)totalBytesExpectedToWrite;
        if (progress) {
             progress(p);
        }
    }];
    
    [operation start];
}

+ (void)uploadFileWithServerUrl:(NSString *)serverUrl
                           Data:(NSData *)data
                       fileName:(NSString *)fileName
                          token:(NSString *)token
                            key:(NSString *)key
                             iv:(NSString *)iv
                       progress:(void(^)(double progress))progress
                     completion:(void(^)(BOOL finished))completion {
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSError *err = nil;
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:serverUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error = nil;
        [formData appendPartWithFileData:data name:@"bin" fileName:[fileName URLEncodedString] mimeType:@"application/file"];
        if (error) {
            NSAssert(0, @"upload file path error.");
        }
    } error:&err];
    
    if (err) {
        NSAssert(0, @"multipartFormRequestWithMethod error.");
    }
    NSString *qid = [fileName stringByDeletingPathExtension];
    NSString *d = [NSString stringWithFormat:@"%@|%@|%@", qid, fileName, [[NSDate Now] formatWith:@"yyyy-MM-dd HH:mm:ss"]];
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[d dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [request setValue:[token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [request setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [request setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    [request setValue:[fileName URLEncodedString] forHTTPHeaderField:@"rc-fn"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             completion(YES);
                                         });
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             completion(NO);
                                         });
                                     }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        double p = totalBytesWritten / (double)totalBytesExpectedToWrite;
        if (progress) {
             progress(p);
        }
       
    }];
    
    [operation start];
}

+ (void)downFileWithServerUrl:(NSString *)serverUrl
                      fileDir:(NSString *)fileDir
                     fileName:(NSString *)fileName
                        token:(NSString *)token
                          key:(NSString *)key
                           iv:(NSString *)iv
                     progress:(void(^)(double progress))progress
                   completion:(void(^)(BOOL finished))completion {
    NSURL *url = [NSURL URLWithString:[serverUrl stringByAppendingPathComponent:[fileName URLEncodedString]]];

    NSString *filePath = [fileDir stringByAppendingPathComponent:fileName];
    NSString *fileTmpPath = [filePath stringByAppendingString:@".tmp"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *qid = [fileName stringByDeletingPathExtension];
    NSString *d = [NSString stringWithFormat:@"%@|%@|%@", qid, fileName, [[NSDate Now] formatWith:@"yyyy-MM-dd HH:mm:ss"]];
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[d dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [request setValue:[token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [request setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [request setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    [request setValue:[fileName URLEncodedString] forHTTPHeaderField:@"rc-fn"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fileTmpPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        double p = totalBytesRead / (double)totalBytesExpectedToRead;
        if (progress) {
             progress(p);
        }
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        [[NSFileManager defaultManager] attributesOfItemAtPath:fileTmpPath error:&error];
            
        if (error) {
            completion(NO);
        } else {
            [[NSFileManager defaultManager] moveItemAtPath:fileTmpPath toPath:filePath error:nil];
            completion(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"下载头像出错。");
        completion(NO);
    }];
    
    [operation start];
}




@end
