//
//  FCMgr.m
//  IM
//
//  Created by 郭志伟 on 15/6/17.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "FCMgr.h"
#import "FCQid.h"
#import "JRSession.h"
#import "User.h"
#import "JRTextResponse.h"
#import "Utils.h"
#import "LogLevel.h"
#import <INTULocationManager.h>
#import "NSUUID+StringUUID.h"
#import "AppDelegate.h"
#import "NSDate+Common.h"
#import "RTFileTransfer.h"
#import "FCNotification.h"

@interface FCMgr() {
    User *_user;
}

@end

@implementation FCMgr

- (instancetype)initWithUser:(User *)user {
    if (self = [super init]) {
        _user = user;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFCNewMsg:) name:kNotificationNewFCMessage object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNewFCMessage object:nil];
}


- (void)getMsgsWithCur:(NSUInteger)cur
                  pgSz:(NSUInteger)pgSz
            completion:(void(^)(BOOL finished, NSDictionary *result))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:_user.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_PYQ_GET_MSGS token:_user.token key:_user.key iv:_user.iv];
    [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)cur] forKey:@"cur"];
    [param.params setObject:[NSString stringWithFormat:@"%lu", (unsigned long)pgSz] forKey:@"pagesize"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([resp isKindOfClass:[JRTextResponse class]]) {
                    JRTextResponse *txtResp = (JRTextResponse *)resp;
                    NSDictionary *dict = [Utils dictFromJsonData:[txtResp.text dataUsingEncoding:NSUTF8StringEncoding]];
                    completion(YES, dict);
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

- (BOOL)hasNewNotification {
    NSNumber *has = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasNewFCMsg"];
    BOOL ret = [has boolValue];
    return ret;
}


- (void)resetNewNotifcatinFlag {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"hasNewFCMsg"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)handleFCNewMsg:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"hasNewFCMsg"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)NewPostWithContent:(NSString *)content
                       imgs:(NSArray *)imgs
                 completion:(void (^)(BOOL))completion {
    __block BOOL uploadResult = YES;
    __block dispatch_group_t serviceGroup = dispatch_group_create();
    __block NSString *uuid = [NSUUID uuid];
    [imgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImage *img = obj;
        NSString *filename = [NSString stringWithFormat:@"%@%u.jpg", uuid, idx+1];
        dispatch_group_enter(serviceGroup);
        [RTFileTransfer uploadFileWithServerUrl:USER.fcImgUploadUrl Data:UIImageJPEGRepresentation(img, 0.9) fileName:filename token:USER.token key:USER.key iv:USER.iv progress:nil completion:^(BOOL finished) {
            dispatch_group_leave(serviceGroup);
            if (!finished) {
                uploadResult = NO;
            }
        }];
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
           if (uploadResult) {
               INTULocationManager *mgr = [INTULocationManager sharedInstance];
               __block CLLocation *location = nil;
               __block NSString *addr = @"未知";
               __block dispatch_group_t locateGrp = dispatch_group_create();
               dispatch_group_enter(locateGrp);
               [mgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:10 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                   if (status == INTULocationStatusSuccess) {
                       location = currentLocation;
                       CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
                       dispatch_group_enter(locateGrp);
                       [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                           if (error) {
                               DDLogError(@"ERROR: %@", error);
                           } else {
                               CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
                               addr = [NSString stringWithFormat:@"%@%@%@", myPlacemark.locality, myPlacemark.subLocality, myPlacemark.thoroughfare];
                           }
                           dispatch_group_leave(locateGrp);
                       }];
                   }
                   dispatch_group_leave(locateGrp);
               }];
               dispatch_group_notify(locateGrp, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:_user.imurl]];
                   JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
                   JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_PYQ_INSERT_MSG token:_user.token key:_user.key iv:_user.iv];
                   [param.params setObject:uuid forKey:@"id"];
                   [param.params setObject:content forKey:@"content"];
                   [param.params setObject:[NSString stringWithFormat:@"%d", imgs.count] forKey:@"imgnum"];
                   [param.params setObject:USER.org forKey:@"org"];
                   [param.params setObject:addr forKey:@"addr"];
                   if (location) {
                       [param.params setObject:[NSString stringWithFormat:@"%f", location.coordinate.longitude] forKey:@"lon"];
                       [param.params setObject:[NSString stringWithFormat:@"%f", location.coordinate.latitude] forKey:@"lat"];
                   }
                   [param.params setObject:@"iphone" forKey:@"platform"];
                   [param.params setObject:[APP_DELEGATE appVersion] forKey:@"version"];__block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       [session request:req success:^(JRReqest *request, JRResponse *resp) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completion(YES);
                           });
                           
                       } failure:^(JRReqest *request, NSError *error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completion(NO);
                           });
                       } cancel:^(JRReqest *request) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completion(NO);
                           });
                       }];
                   });
               });
               
           } else {
               completion(NO);
           }
           
       });
    });
}

- (void)replyMsgWithId:(NSString *)msgId
               replyId:(NSString *)replyId
              replyUid:(NSString *)replyUid
               content:(NSString *)content
            completion:(void(^)(BOOL finished))completion{
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:_user.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_PYQ_INSERT_REPLY token:_user.token key:_user.key iv:_user.iv];
    
    [param.params setObject:[NSUUID uuid] forKey:@"hfxxid"];
    [param.params setObject:msgId forKey:@"ssid"];
    if (replyId) {
         [param.params setObject:replyId forKey:@"sshfxxid"];
    }
    [param.params setObject:content forKey:@"content"];
    [param.params setObject:USER.org forKey:@"hfrjgbm"];
    [param.params setObject:@"iphone" forKey:@"platform"];
    [param.params setObject:APP_DELEGATE.appVersion forKey:@"version"];
    [param.params setObject:[[NSDate Now] formatWith:nil] forKey:@"scsj"];
    if (replyUid) {
        [param.params setObject:replyUid forKey:@"bhfr"];
    }
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
            
        } failure:^(JRReqest *request, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            
        } cancel:^(JRReqest *request) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }];
    });

}

@end
