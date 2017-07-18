//
//  PwdMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-9.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "PwdMgr.h"
#import "JRSession.h"
#import "JRTextResponse.h"

@implementation PwdMgr

+ (void) changePwdWithOldPwd:(NSString *)oldPwd
                     newPwd:(NSString *)newPwd
                      Token:(NSString *)token
                  signature:(NSString *)signature
                        key:(NSString *)key
                         iv:(NSString *)iv
                        url:(NSString *)url
                 completion:(void(^)(BOOL finished)) completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:@"QID_IM_SET_USER_PWD" token:token key:key iv:iv];
    [param.params setObject:oldPwd forKey:@"pwd_old"];
    [param.params setObject:newPwd forKey:@"pwd_new"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTextResponse class]]) {
                JRTextResponse *txtResp = (JRTextResponse *)resp;
                if ([txtResp.text isEqualToString:@"1"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO);
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
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
