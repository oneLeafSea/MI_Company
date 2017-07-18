//
//  AvatarMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTFileTransfer.h"
#import <FMDB.h>


@interface AvatarMgr : NSObject

- (instancetype)initWithAvatarPath:(NSString *)avatarPath dbq:(FMDatabaseQueue *)dbq;

- (void) getAvatarsByUserIds:(NSArray *)userIds;

- (void) getAvatarWithToken:(NSString *)token
                        key:(NSString *)key
                         iv:(NSString *)iv
                  signature:(NSString *)singnature
                     userId:(NSString *)userId
                        url:(NSString *)url
             checkUrlString:(NSString *)checkUrlString
                 completion:(void(^)(BOOL finished, NSError *error))completion;

- (UIImage *) getAvatarImageByUid:(NSString *)uid;


- (void)syncAvatarVerWithCompletion:(void(^)(BOOL finished, NSError *error))completion;

@property(nonatomic, readonly) NSString *avatarPath;

@end
