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

@interface FCMgr() {
    User *_user;
}

@end

@implementation FCMgr

- (instancetype)initWithUser:(User *)user {
    if (self = [super init]) {
        _user = user;
    }
    return self;
}


- (void)getMsgsWithCur:(NSUInteger)cur
                  pgSz:(NSUInteger)pgSz
            completion:(void(^)(BOOL finished, NSDictionary *result))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:_user.imurl]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_PYQ_GET_MSGS token:_user.token key:_user.key iv:_user.iv];
    [param.params setObject:[NSString stringWithFormat:@"%d", cur] forKey:@"cur"];
    [param.params setObject:[NSString stringWithFormat:@"%d", pgSz] forKey:@"pagesize"];
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

- (void)postANewMsg {
    INTULocationManager *mgr = [INTULocationManager sharedInstance];
    [mgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:10 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
            [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    DDLogError(@"ERROR: %@", error);
                }
                CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
                NSString *addr = [NSString stringWithFormat:@"%@%@%@", myPlacemark.locality, myPlacemark.subLocality, myPlacemark.thoroughfare];
                __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:_user.imurl]];
                JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
                JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_PYQ_INSERT_MSG token:_user.token key:_user.key iv:_user.iv];
                [param.params setObject:[NSUUID uuid] forKey:@"id"];
                [param.params setObject:@"你好！ 朋友圈" forKey:@"content"];
                [param.params setObject:@"0" forKey:@"imgnum"];
                [param.params setObject:USER.org forKey:@"org"];
                [param.params setObject:addr forKey:@"addr"];
                [param.params setObject:[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude] forKey:@"lon"];
                [param.params setObject:[NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude] forKey:@"lat"];
                [param.params setObject:@"iphone" forKey:@"platform"];
                [param.params setObject:[APP_DELEGATE appVersion] forKey:@"version"];
                
                __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [session request:req success:^(JRReqest *request, JRResponse *resp) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([resp isKindOfClass:[JRTextResponse class]]) {
                                JRTextResponse *txtResp = (JRTextResponse *)resp;
                                if ([txtResp.text isEqualToString:@"1"]) {
                                    NSLog(@"发送朋友圈成功");
                                }
                            } else {
                                
                            }
                            
                        });
                        
                    } failure:^(JRReqest *request, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
//                            completion(NO, nil);
                        });
                        
                    } cancel:^(JRReqest *request) {
//                        completion(NO, nil);
                    }];
                });
            }];
        } else if (status == INTULocationStatusTimedOut) {
            DDLogInfo(@"INFO: Get gps timeout");
        } else {
            DDLogInfo(@"INFO: Get gps error");
        }
    }];
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
