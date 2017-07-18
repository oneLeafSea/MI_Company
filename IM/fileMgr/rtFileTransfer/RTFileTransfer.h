//
//  RTFileTransfer.h
//  IM
//
//  Created by 郭志伟 on 15/6/17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RTFileTransfer : NSObject

+ (void)downFileWithServerUrl:(NSString *)serverUrl
                      fileDir:(NSString *)fileDir
                     fileName:(NSString *)fileName
                        token:(NSString *)token
                          key:(NSString *)key
                           iv:(NSString *)iv
                     progress:(void(^)(double progress))progress
                   completion:(void(^)(BOOL finished))completion;


+ (void)uploadFileWithServerUrl:(NSString *)serverUrl
                       filePath:(NSString *)filePath
                          token:(NSString *)token
                            key:(NSString *)key
                             iv:(NSString *)iv
                       progress:(void(^)(double progress))progress
                     completion:(void(^)(BOOL finished))completion;

+ (void)uploadFileWithServerUrl:(NSString *)serverUrl
                           Data:(NSData *)data
                       fileName:(NSString *)fileName
                          token:(NSString *)token
                            key:(NSString *)key
                             iv:(NSString *)iv
                       progress:(void(^)(double progress))progress
                     completion:(void(^)(BOOL finished))completion;

@end
