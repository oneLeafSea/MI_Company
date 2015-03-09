//
//  groupChatMgr.h
//  IM
//
//  Created by 郭志伟 on 15-3-2.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupChatList.h"
#import "GroupChat.h"

@interface GroupChatMgr : NSObject

- (void)getGroupListWithToken:(NSString *)token
                    signature:(NSString *)signature
                          key:(NSString *)key
                           iv:(NSString *)iv
                          url:(NSString *)url
                   completion:(void(^)(BOOL finished))completion;

- (void)getGroupPeerListWithGid:(NSString *)gid
                          token:(NSString *)token
                        signatrue:(NSString *)signature
                              key:(NSString *)key
                               iv:(NSString *)iv
                              url:(NSString *)url
                       completion:(void(^)(BOOL finished))completion;

@property(readonly) GroupChatList *grpChatList;

- (GroupChat *)getGrpChatByGid:(NSString *)gid;

@end