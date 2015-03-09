//
//  groupChatMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "GroupChatMgr.h"
#import "JRSession.h"
#import "GroupChatQid.h"
#import "JRTableResponse.h"

@implementation GroupChatMgr

- (void)getGroupListWithToken:(NSString *)token
                    signature:(NSString *)signature
                          key:(NSString *)key
                           iv:(NSString *)iv
                          url:(NSString *)url
                   completion:(void(^)(BOOL finished))completion{
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_GROUP_LIST token:token key:key iv:iv];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                JRTableResponse *tbResp = (JRTableResponse *)resp;
                _grpChatList = [[GroupChatList alloc] initWithGrpInfo:tbResp.result];
                if (_grpChatList) {
                    completion(YES);
                } else {
                    completion(NO);
                }
            } else {
                completion(NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
    
}

- (void)getGroupPeerListWithGid:(NSString *)gid
                          token:(NSString *)token
                      signatrue:(NSString *)signature
                            key:(NSString *)key
                             iv:(NSString *)iv
                            url:(NSString *)url
                     completion:(void(^)(BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_GROUP_PEER_LIST token:token key:key iv:iv];
    [param.params setObject:gid forKey:@"gid"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRTableResponse class]]) {
                JRTableResponse *tbResp = (JRTableResponse *)resp;
                GroupChat *grp = [self getGrpChatByGid:gid];
                completion([grp parseItems:tbResp.result]);
            } else {
                completion(NO);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
}

- (GroupChat *)getGrpChatByGid:(NSString *)gid {
    __block GroupChat *grp = nil;
    [self.grpChatList.grpChatList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GroupChat *group = obj;
        if ([group.gid isEqualToString:gid]) {
            grp = group;
            *stop = YES;
        }
    }];
    return grp;
}

@end
