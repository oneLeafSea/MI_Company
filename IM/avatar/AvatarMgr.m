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
#import "AvatarTb.h"
#import "AvatarVerTb.h"
#import "AvatarTb.h"
#import "JRTextResponse.h"

@interface AvatarMgr() {
    NSString *m_avatarPath;
}
@property(weak) FMDatabaseQueue *dbq;
@property(nonatomic, strong)AvatarTb        *avatarTb;
@property(nonatomic, strong)AvatarVerTb     *avatarVerTb;

@end

@implementation AvatarMgr

- (instancetype)initWithAvatarPath:(NSString *)avatarPath dbq:(FMDatabaseQueue *)dbq {
    if (self = [super init]) {
        m_avatarPath = [avatarPath copy];
        self.dbq = dbq;
    }
    return self;
}



- (void) getAvatarsByUserIds:(NSArray *)userIds {
    [userIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self needUpdateWithUid:obj]) {
            NSString *filePath = [self getAvatarPathByUid:obj];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                if (!ret) {
                    DDLogInfo(@"删除失败");
                }
            }
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
       if (finished) {
           [self.avatarTb updateAvatarSuccessWithUid:userId];
       }
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
    }
    if ([self needUpdateWithUid:uid]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
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

- (void)syncAvatarVerWithCompletion:(void(^)(BOOL finished, NSError *error))completion {
    
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:USER.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:@"QID_IM_GET_CONTACTS_AVATAR" token:USER.token key:USER.key iv:USER.iv];
    NSString *ver = [self.avatarVerTb getVersion];
    [param.params setObject:ver forKey:@"ver"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([resp isKindOfClass:[JRTextResponse class]]) {
                    JRTextResponse *txtResp = (JRTextResponse *)resp;
                    NSArray *array = [Utils arrayFromJsonData:[txtResp.text dataUsingEncoding:NSUTF8StringEncoding]];
                    NSDictionary *ext = txtResp.ext;
                    if (array.count > 0) {
                        BOOL ret = [self.avatarTb updateWithArray:array];
                        if (ret) {
                            if (ext) {
                                NSString *ver = [ext objectForKey:@"ver"];
                                ret = [self.avatarVerTb updateVersion:ver];
                                if (ret) {
                                    completion(YES, nil);
                                } else {
                                    completion(NO, nil);
                                }
                            } else {
                                completion(YES, nil);
                            }
                        }
                    } else {
                        completion(YES, nil);
                    }
                } else {
                    completion(NO, nil);
                }
                
            });
            
        } failure:^(JRReqest *request, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil);
            });
            
        } cancel:^(JRReqest *request) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil);
            });
        }];
    });

}

- (BOOL)needUpdateWithUid:(NSString *)uid {
    return [self.avatarTb needUpdateForUid:uid];
}

- (AvatarVerTb *)avatarVerTb {
    if (_avatarVerTb == nil) {
        _avatarVerTb = [[AvatarVerTb alloc] initWithDbq:self.dbq];
    }
    return _avatarVerTb;
}

- (AvatarTb *)avatarTb {
    if (_avatarTb == nil) {
        _avatarTb = [[AvatarTb alloc] initWithDbq:self.dbq];
    }
    return _avatarTb;
}





@end
