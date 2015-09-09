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
#import "session.h"

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

- (void)getGroupOfflineMsgWithGid:(NSString *)gid
                            Token:(NSString *)token
                        signature:(NSString *)signature
                              key:(NSString *)key
                               iv:(NSString *)iv
                              url:(NSString *)url
                       completion:(void(^)(BOOL finished))completion;

- (void)createTempGroupWithGName:(NSString *)gName
                           fname:(NSString *)fName
                          token:(NSString *)token
                      signatrue:(NSString *)signature
                            key:(NSString *)key
                             iv:(NSString *)iv
                            url:(NSString *)url
                     completion:(void(^)(NSString* gid, BOOL finished))completion;

- (void)invitePeers:(NSArray *)peers
              toGid:(NSString *)gid
              gname:(NSString *)gname
            session:(Session *)session
         completion:(void(^)(BOOL finished))completion;

- (void)delGrpWithGid:(NSString *)gid
              session:(Session *)session
           completion:(void(^)(BOOL finished))completion;

- (void)quitGrpWithGid:(NSString *)gid
               session:(Session *)session
            completion:(void(^)(BOOL finished))completion;



@property(strong, atomic) GroupChatList *grpChatList;

- (GroupChat *)getGrpChatByGid:(NSString *)gid;

@end
