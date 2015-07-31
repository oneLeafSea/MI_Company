//
//  AvatarMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "AvatarMgr.h"
#import "JRSession.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "AvatarNotifications.h"
#import "LogLevel.h"

@interface AvatarMgr() {
    NSString *m_avatarPath;
}
@end

@implementation AvatarMgr

- (instancetype)initWithAvatarPath:(NSString *)avatarPath {
    if (self = [super init]) {
        m_avatarPath = [avatarPath copy];
    }
    return self;
}

- (void) getAvatarsByUserIds:(NSArray *)userIds {
    [userIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self getAvatarPathByUid:obj]]) {
            [self getAvatarWithToken:USER.token key:USER.key iv:USER.iv signature:USER.signature userId:obj url:USER.avatarUrl checkUrlString:USER.avatarCheckUrl completion:^(BOOL finished, NSError *error) {
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kAvatarNotificationDownloaded object:[obj copy]];
                    });
                }
            }];
        }
    }];
}

- (void) getAvatarWithToken:(NSString *)token
                        key:(NSString *)key
                         iv:(NSString *)iv
                  signature:(NSString *)signature
                     userId:(NSString *)userId
                        url:(NSString *)url
             checkUrlString:(NSString *)checkUrlString
                 completion:(void(^)(BOOL finished, NSError *error))cpt {
   [RTFileTransfer downFileWithServerUrl:url fileDir:m_avatarPath fileName:[NSString stringWithFormat:@"%@.jpg", userId] token:token key:key iv:iv progress:nil completion:^(BOOL finished) {
       cpt(finished, nil);
   }];
}

- (NSString *)getAvatarTmpPathByUid:(NSString *)uid {
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg.tmp", uid];
    return [m_avatarPath stringByAppendingPathComponent:imgName];
}

- (NSString *)getAvatarPathByUid:(NSString *)uid {
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", uid];
    return [m_avatarPath stringByAppendingPathComponent:imgName];
}

- (UIImage *) getAvatarImageByUid:(NSString *)uid {
    UIImage *img = nil;
    NSString *filePath = [self getAvatarPathByUid:uid];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        img = [UIImage imageWithContentsOfFile:filePath];
    } else {
        img = [UIImage imageNamed:@"avatar_default"];
        [self getAvatarWithToken:USER.token key:USER.key iv:USER.iv signature:USER.signature userId:uid url:USER.avatarUrl checkUrlString:USER.avatarCheckUrl completion:^(BOOL finished, NSError *error) {
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAvatarNotificationDownloaded object:[uid copy]];
                });
            }
        }];
        
    }
    if (!img) {
        img = [UIImage imageNamed:@"avatar_default"];
    }
    return img;
}

- (NSString *)avatarPath {
    return m_avatarPath;
}

@end
