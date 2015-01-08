//
//  RosterAddRequest.h
//  IM
//
//  Created by 郭志伟 on 14-12-17.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "Request.h"

typedef  NS_ENUM(UInt32, RosterItemAddReqStatus) {
    RosterItemAddReqStatusUnkown,
    RosterItemAddReqStatusRequesting,
    RosterItemAddReqStatusACK,
    RosterItemAddReqStatusError
};

@interface RosterItemAddRequest : Request

- (instancetype)initWithFrom:(NSString *)from
                     to:(NSString *)to
                    groupId:(NSString *)gid
                     reqmsg:(NSString *)reqmsg
                    selfName:(NSString *)selfName;

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                        msgid:(NSString *)msgid
                        msg:(NSString *)msg
                      status:(NSNumber *)status;

- (instancetype) initWithData:(NSData *)data;
- (NSData *)pkgData;

@property(copy, readonly) NSString *from;
@property(copy, readonly) NSString *to;
@property(copy, readonly) NSString *gid;
@property(copy, readonly) NSString *reqmsg;
@property(copy, readonly) NSString *selfName;

@property(readonly) NSString *msg;

@property RosterItemAddReqStatus status;
@end
