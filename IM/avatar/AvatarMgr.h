//
//  AvatarMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileTransfer.h"


@interface AvatarMgr : NSObject

- (instancetype)initWithAvatarPath:(NSString *)avatarPath;

- (void) getAvatarsByUserIds:(NSArray *)userIds;

- (void) getAvatarWithToken:(NSString *)token
                  signature:(NSString *)singnature
                     userId:(NSString *)userId
                        url:(NSString *)url
             checkUrlString:(NSString *)checkUrlString
               fileTransfer:(FileTransfer *)fileTransfer
                 completion:(void(^)(BOOL finished, NSError *error))completion;

- (UIImage *) getAvatarImageByUid:(NSString *)uid;


@end
