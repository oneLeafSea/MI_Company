//
//  FileTransfer.h
//  IM
//
//  Created by 郭志伟 on 15-1-29.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileTransfer : NSObject

/**
 * download file from file server.
 * @param filename which is getted from server.
 * @param urlstring the file server url.
 * @param checkUrlString check the file md5sum server.
 * @param options contains key: token signature and file path.
 * @param completion retrun the result.
 **/

- (void)downloadFileName:(NSString *)fileName
               urlString:(NSString *)urlString
          checkUrlString:(NSString *)checkUrlString
                 options:(NSDictionary *)options
              completion:(void(^)(BOOL finished, NSError *error))completion;

/**
 * upload file to file server.
 * @param filename which is getted from server.
 * @param urlstring the file server url.
 * @param checkUrlString check the file md5sum server.
 * @param options contains key: token signature and file path.
 * @param completion retrun the result.
 **/

- (void)uploadFileName:(NSString *)fileName
             urlString:(NSString *)urlString
        checkUrlString:(NSString *)checkUrlString
     completeUrlString:(NSString *)completeUrlString
               options:(NSDictionary *)options
            completion:(void(^)(BOOL finished, NSError *error))completion;


- (BOOL)exsitTask:(NSString *)filename;

@end
