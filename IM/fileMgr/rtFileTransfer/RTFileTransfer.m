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

@implementation RTFileTransfer

+ (void)uploadFileWithServerUrl:(NSString *)serverUrl {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    __block UIImage *img = [UIImage imageNamed:@"fc_demo"];
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *key = USER.key;
    NSString *iv = USER.iv;
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    NSString *fileName = [@"这是个中文4.png" URLEncodedString];
    [manager.requestSerializer setValue:[USER.token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [manager.requestSerializer setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [manager.requestSerializer setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    [manager.requestSerializer setValue:fileName forHTTPHeaderField:@"rc-fn"];
    
    [manager POST:serverUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(img) name:@"bin" fileName:fileName mimeType:@"img/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+ (void)uploadFileWithServerUrl:(NSString *)serverUrl
                       filePath:(NSString *)filePath
                          token:(NSString *)token
                            key:(NSString *)key
                             iv:(NSString *)iv
                       progress:(void(^)(double progress))progress
                     completion:(void(^)(BOOL finished))completion {
    
    __block NSString *fileName = [filePath lastPathComponent];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSError *err = nil;
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:serverUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:serverUrl] name:@"bin" fileName:[fileName URLEncodedString] mimeType:@"application/file" error:&error];
        if (error) {
            NSAssert(0, @"upload file path error.");
        }
    } error:&err];
    
    if (err) {
        NSAssert(0, @"multipartFormRequestWithMethod error.");
    }
    
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [request setValue:[token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [request setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [request setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    [request setValue:[fileName URLEncodedString] forHTTPHeaderField:@"rc-fn"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                     }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {

        double p = totalBytesWritten / (double)totalBytesExpectedToWrite;
        progress(p);
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
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
        [formData appendPartWithFileData:data name:@"bin" fileName:[fileName URLDecodedString] mimeType:@"application/file"];
        if (error) {
            NSAssert(0, @"upload file path error.");
        }
    } error:&err];
    
    if (err) {
        NSAssert(0, @"multipartFormRequestWithMethod error.");
    }
    
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [request setValue:[token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [request setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [request setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    [request setValue:[fileName URLEncodedString] forHTTPHeaderField:@"rc-fn"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                     }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        double p = totalBytesWritten / (double)totalBytesExpectedToWrite;
        progress(p);
    }];
    
    [operation start];
}

+ (void)downFileWithServerUrl:(NSString *)serverUrl {
    NSString *strUrl = [NSString stringWithFormat:@"http://10.22.1.112:8040/file/download/%@", [@"这是个中文4.png" URLEncodedString]];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *key = USER.key;
    NSString *iv = USER.iv;
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [request setValue:[USER.token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [request setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [request setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[url lastPathComponent] URLDecodedString]];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            NSLog(@"%@", [NSString stringWithFormat:@"%lld", fileSize]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
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
    NSString *filePath = [fileDir stringByAppendingString:fileName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *qid = [NSString stringWithFormat:@"%@|%@", [NSUUID uuid], [[NSDate Now] formatWith:nil]];
    NSString *sign = [Encrypt encodeWithKey:key iv:iv data:[qid dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [request setValue:[token URLEncodedString] forHTTPHeaderField:@"rc-token"];
    [request setValue:[qid URLEncodedString] forHTTPHeaderField:@"rc-qid"];
    [request setValue:[sign URLEncodedString] forHTTPHeaderField:@"rc-signature"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        double p = totalBytesRead / (double)totalBytesExpectedToRead;
        progress(p);

    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            
        if (error) {
            completion(NO);
        } else {
            completion(YES);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
        completion(NO);
    }];
    
    [operation start];
}




@end
